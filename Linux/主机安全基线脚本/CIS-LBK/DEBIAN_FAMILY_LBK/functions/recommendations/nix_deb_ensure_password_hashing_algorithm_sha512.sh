#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_password_hashing_algorithm_sha512.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure password hashing algorithm is SHA-512"
# 
deb_ensure_password_hashing_algorithm_sha512()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" file=""
	# Test is system-auth file is configured
	if grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/common-password; then
		test=passed
	else
		file="/etc/pam.d/common-password"
		if grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s+)?(md5)(.*)$/\2\3\4\5 sha512 \7/' "$file"
		elif grep -Eqs 'password\s+(\S+)\s+pam_unix\.so\s+' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s*)?(\s*#.*)?$/\2\3\4\5 sha512 \6/' "$file"
		else
			if grep -Eq '^\s*#\s+end\s+of\s+pam-auth-update\s+config' "$file"; then
				sed -ri '/password\s+(\S+)\s+pam_deny\.so\s*/ i  password [success=1 default=ignore] pam_unix.so sha512' "$file"
			else
				echo "password [success=1 default=ignore] pam_unix.so sha512" "$file"
			fi
		fi
		grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' "$file" && test=remediated
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