#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_default_user_umask_027_more_restrictive_v2.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure default user umask is 027 or more restrictive"
# Eric Pinnell       11/30/20    created v2 to be case insensitive, add /etc/login.defs to search, and change setting to /etc/login.defs
# 
ensure_default_user_umask_027_more_restrictive_v2()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	test1="" test2=""
	#Set the location of bashrc
	[ -f /etc/bashrc ] && BRC="/etc/bashrc"
	[ -f /etc/bash.bashrc ] && BRC="/etc/bash.bashrc"
	# Check if umask is set correctly
	for file in /etc/profile /etc/profile.d* /etc/login.defs "$BRC"*; do
		if ! grep -Ev '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' "$file" | grep -Eiq '(^|^[^#]+\s+)umask'; then
			[ -z "$test1" ] && test1=passed
		else
			sed -ri 's/^([^#]+\s+)?(umask\s+)(\S+\s*)(\s+.*)?$/\1\2027\4/gI' "$file"
			! grep -Eiv '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' "$file" | grep -Eiq '(^|^[^#]+\s+)umask' && test1=remediated || test=failed
		fi
	done

	if grep -Eiqs '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile /etc/profile.d* /etc/login.defs "$BRC"*; then
		test2=passed
	else
		if find / -name pam_umask.so >/dev/null; then
			# Setting pam_umask.so
			if grep -Eiq 'umask\s+[0-9][0-9][0-9]' /etc/login.defs; then
				sed -ri 's/^([^#]+\s+)?(umask\s+)(\S+\s*)(\s+.*)?$/\1\2027\4/gI' /etc/login.defs
			else
				echo "UMASK 027" >> /etc/login.defs
			fi
			if ! grep -Eq '^\s*session\s+optional\s+pam_umask.so\b' /etc/pam.d/common-session; then
				grep '# end of pam-auth-update config' /etc/pam.d/common-session && sed -ri '/# end of pam-auth-update config/i session optional        pam_umask.so' /etc/pam.d/common-session || echo "session optional        pam_umask.so" >> /etc/pam.d/common-session
			fi
			grep -Eqi '^\s*UMASK\s+027\b' /etc/login.defs && grep -Eq '^\s*session\s+optional\s+pam_umask.so\b' /etc/pam.d/common-session && test2=remediated
		else
			echo "umask 027" >> /etc/profile.d/cis_profile.sh
			grep -Eiqs '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile /etc/profile.d* /etc/login.defs "$BRC"* && test2=remediated
		fi
	fi

	# Adding umask to /etc/profile.d/cis_profile.sh if it doesn't already exist.  This won't break anything.
	! grep -Eiqs '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile /etc/profile.d* /etc/login.defs "$BRC"* && echo "umask 027" >> /etc/profile.d/cis_profile.sh
	# Check test status
	[ "$test1" = "failed" ] && test1="" 
	if [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi

	# Set return code and return
	case "$test" in
		passed)
			echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo "Recommendation \"$RNA\" requires manual remediation" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}