#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_default_user_shell_timeout_900_seconds_less.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure default user shell timeout is 900 seconds or less"
# 
ensure_default_user_shell_timeout_900_seconds_less()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	#Set the location of bashrc
	[ -f /etc/bashrc ] && BRC="/etc/bashrc"
	[ -f /etc/bash.bashrc ] && BRC="/etc/bash.bashrc"
	# Check if TMOUT is set
	for file in "$BRC" /etc/profile /etc/profile.d/*.sh ; do
		if [ -f "$file" ]; then
			grep -Eq '(^|^[^#]*;)\s*(readonly|export(\s+[^$#;]+\s*)*)?\s*TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$file" && grep -Eq '(^|^[^#]*;)\s*readonly\s+TMOUT\b' "$file" && grep -Eq '(^|^[^#]*;)\s*export\s+([^$#;]+\s+)*TMOUT\b' "$file" && test1=passed
		else
			break
		fi
	done
	# Check that TMOUT is not "overridden" in another location
	! grep -Pqs '(^|^[^#]*;)\s*TMOUT=(9[0-9][1-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" && test2=passed
	
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		# Add TMOUT if it's not set correctly
		for file in "$BRC" /etc/profile /etc/profile.d/*.sh ; do
			if [ -f "$file" ]; then
				if grep -Eqs '^\s*([^#]+\s+)?(readonly\s+)?(TMOUT\s*=\s*)(9[0-9][1-9]|[1-9][0-9][0-9][0-9]+)([^;#]+)?(;\s*export\s+(\S+\s+)*TMOUT\b)?(.*)$' "$file"; then
					sed -ri 's/^\s*([^#]+\s+)?(readonly\s+)?(TMOUT\s*=\s*)(9[0-9][1-9]|[1-9][0-9][0-9][0-9]+)([^;#]+)?(;\s*export\s+(\S+\s+)*TMOUT\b)?(.*)$/# &/' "$file"
					grep -Eqs '^\s*([^#]+\s+)?(readonly\s+TMOUT\b)' "$file" && sed -ri 's/^\s*([^#]+\s+)?(readonly\s+TMOUT\b)(.*)$/# &/' "$file"
					grep -Eqs '^\s*([^#]+\s+)?(export\s+TMOUT\b)' "$file" && sed -ri 's/^\s*([^#]+\s+)?(export\s+TMOUT\b)(.*)$/# &/' "$file"
				fi
			fi
		done
		for file in "$BRC" /etc/profile /etc/profile.d/*.sh ; do
		if [ -f "$file" ]; then
			grep -Eq '(^|^[^#]*;)\s*(readonly|export(\s+[^$#;]+\s*)*)?\s*TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$file" && grep -Eq '(^|^[^#]*;)\s*readonly\s+TMOUT\b' "$file" && grep -Eq '(^|^[^#]*;)\s*export\s+([^$#;]+\s+)*TMOUT\b' "$file" && test1=remediated
		else
			break
		fi
		done
		if [ "$test1" = remediated ]; then
			test=remediated
		else
			echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile.d/cis_profile.sh
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