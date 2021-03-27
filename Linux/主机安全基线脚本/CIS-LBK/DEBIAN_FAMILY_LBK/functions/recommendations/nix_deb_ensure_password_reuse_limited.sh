#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_password_reuse_limited.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure password reuse is limited"
# 
deb_ensure_password_reuse_limited()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Test if system-auth file is configured
	file="/etc/pam.d/common-password"
	if grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file"; then
		test=passed
	else
		if grep -Eqs 'password\s+(requisite|required)\s+pam_pwhistory\.so(\s+[^#]+\s+)?\s*remember=' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s+)?(remember=)(\S++\b)(.*)$/\2\4\55 \7/' "$file"
		elif grep -Es 'password\s+(requisite|required)\s+pam_pwhistory\.so' "$file" | grep -vq 'remember='; then
			sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s*)?(#.*)?$/\2\4 remember=5\5/' "$file"
		else
			if grep -Eq "^\s*#\s+end\s+of\s+pam-auth-update\s+config" "$file"; then
				sed -ri '/^\s*#\s+end\s+of\s+pam-auth-update\s+config/ i password    required      pam_pwhistory.so remember=5' "$file"
			else
				echo "password    required      pam_pwhistory.so remember=5" "$file"
			fi
		fi
		grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file" && test=remediated
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