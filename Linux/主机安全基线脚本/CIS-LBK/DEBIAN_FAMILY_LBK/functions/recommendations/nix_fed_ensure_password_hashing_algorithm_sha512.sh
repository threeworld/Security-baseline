#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_password_hashing_algorithm_sha512.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/05/20    Recommendation "Ensure password hashing algorithm is SHA-512"
# 
fed_ensure_password_hashing_algorithm_sha512()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" file=""
	# Test is system-auth file is configured
	if grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/system-auth; then
		test1=passed
	else
		file="/etc/pam.d/system-auth"
		if grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s+)?(md5)(.*)$/\2\3\4\5 sha512 \7/' "$file"
		elif grep -Eqs 'password\s+(\S+)\s+pam_unix\.so\s+' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s*)?(\s*#.*)?$/\2\3\4\5 sha512 \6/' "$file"
		else
			sed -ri '/password\s+(\S+)\s+pam_deny\.so\s*/ i  password    sufficient                                   pam_unix.so sha512 shadow  try_first_pass use_authtok  remember=5' "$file"
		fi
		grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file" && test1=remediated
	fi
	# Test is password-auth file is configured
	if grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/password-auth; then
		test2=passed
	else
		file="/etc/pam.d/password-auth"
		if grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s+)?(md5)(.*)$/\2\3\4\5 sha512 \7/' "$file"
		elif grep -Eqs 'password\s+(\S+)\s+pam_unix\.so\s+' "$file"; then
			sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s*)?(\s*#.*)?$/\2\3\4\5 sha512 \6/' "$file"
		else
			sed -ri '/password\s+(\S+)\s+pam_deny\.so\s*/ i  password    sufficient                                   pam_unix.so sha512 shadow  try_first_pass use_authtok  remember=5' "$file"
		fi
		grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/password-auth && test2=remediated
	fi
	# Check for recommendation passing state
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