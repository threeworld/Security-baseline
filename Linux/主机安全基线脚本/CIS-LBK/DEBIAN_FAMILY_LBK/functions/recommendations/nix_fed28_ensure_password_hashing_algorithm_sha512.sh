#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_password_hashing_algorithm_sha512.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/28/20    Recommendation "Ensure password hashing algorithm is SHA-512"
# 
fed28_ensure_password_hashing_algorithm_sha512()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	# test if custom profile is in use, otherwise set custom profile if possible
	if [ -n "$(authselect current | awk '/custom\// {print $3}')" ]; then
		cpro=$(authselect current | awk '/custom\// {print $3}')
	else
		custprofile="$(authselect list | awk -F / '/custom\// { print $2 }' | cut -f1)"
		if [ "$(echo "$custprofile" | awk '{total=total+NF};END{print total}')" = 1 ]; then
			authselect select custom/"$custprofile" with-sudo with-faillock without-nullok --force
			cpro=$(authselect current | awk '/custom\// {print $3}')
		else
			test=manual
		fi
	fi
	# Test is system-auth file is configured
	if grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/system-auth; then
		test1=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/system-auth" ]; then
			file="/etc/authselect/$cpro/system-auth"
			if grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s+)?(md5)(.*)$/\2\3\4\5 sha512 \7/' "$file"
			elif grep -Eqs 'password\s+(\S+)\s+pam_unix\.so\s+' "$file"; then
				sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s*)?(\s*#.*)?$/\2\3\4\5 sha512 \6/' "$file"
			else
				sed -ri '/password\s+(\S+)\s+pam_deny\.so\s*/ i  password    sufficient                                   pam_unix.so sha512 shadow  try_first_pass use_authtok  remember=5' "$file"
			fi
		fi
	fi
	# Test is password-auth file is configured
	if grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/password-auth; then
		test2=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/password-auth" ]; then
			file="/etc/authselect/$cpro/password-auth"
			if grep -Eqs 'password\s+(\S+)\s+pam_unix\.so(\s+[^#]+\s+)?\s*(md5)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s+)?(md5)(.*)$/\2\3\4\5 sha512 \7/' "$file"
			elif grep -Eqs 'password\s+(\S+)\s+pam_unix\.so\s+' "$file"; then
				sed -ri 's/^\s*(#\s*)?(password\s+)(\S+)(\s+pam_unix\.so\s+)([^#]+\s*)?(\s*#.*)?$/\2\3\4\5 sha512 \6/' "$file"
			else
				sed -ri '/password\s+(\S+)\s+pam_deny\.so\s*/ i  password    sufficient                                   pam_unix.so sha512 shadow  try_first_pass use_authtok  remember=5' "$file"
			fi
		fi
	fi
	# Check for recommendation passing state
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	elif [ "$test" != manual ]; then
		[ -n "$cpro" ] && authselect apply-changes
		grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/system-auth && test1=remediated
		grep -Eqs '^\s*password\s+(\S+\s+)+pam_unix\.so\s+([^#]+\s+)?sha512\b' /etc/pam.d/password-auth && test2=remediated
		[ -n "$test1" ] && [ -n "$test2" ] && test=remediated
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