#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_default_user_umask_027_more_restrictive.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure default user umask is 027 or more restrictive"
# 
ensure_default_user_umask_027_more_restrictive()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	test1="" test2=""
	#Set the location of bashrc
	[ -f /etc/bashrc ] && BRC="/etc/bashrc"
	[ -f /etc/bash.bashrc ] && BRC="/etc/bash.bashrc"
	# Check if umask is set correctly

	for file in /etc/profile /etc/profile.d/*.sh "$BRC"; do
		if ! grep -Ev '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' "$file" | grep -Eq '(^|^[^#]+\s+)umask'; then
			[ -z "$test1" ] && test1=passed
		else
			test1=remediated
			sed -ri 's/^([^#]+\s+)?(umask\s+)(\S+\s*)(\s+.*)?$/\1\2 027\4/' "$file"
		fi
	done

	if grep -E '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile /etc/profile.d/*.sh "$BRC"; then
		test2=passed
	else
		echo "umask 027" >> /etc/profile.d/cis_profile.sh
		grep -E '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile /etc/profile.d/*.sh "$BRC" && test2=remediated
	fi

	# Adding umask to /etc/profile.d/cis_profile.sh if it doesn't already exist.  This won't break anything.
	! grep -E '^\s*umask\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\s*(\s*#.*)?$' /etc/profile.d/cis_profile.sh && echo "umask 027" >> /etc/profile.d/cis_profile.sh
	# Check test status
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