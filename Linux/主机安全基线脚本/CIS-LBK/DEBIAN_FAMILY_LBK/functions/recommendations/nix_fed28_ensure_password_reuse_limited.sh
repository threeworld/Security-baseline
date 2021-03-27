#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_password_reuse_limited.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/28/20    Recommendation "Ensure password reuse is limited"
# 
fed28_ensure_password_reuse_limited()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	test3=""
	# test if custom profile is in use, otherwise set custom profile if possible
	cpro=$(authselect current | awk '/custom\// {print $3}')
	if [ -z "$cpro" ]; then
		custprofile="$(authselect list | awk -F / '/custom\// { print $2 }' | cut -f1)"
		if [ "$(echo "$custprofile" | awk '{total=total+NF};END{print total}')" = 1 ]; then
			authselect select custom/"$custprofile" with-sudo with-faillock without-nullok --force	
			cpro=$(authselect current | awk '/custom\// {print $3}')			
		else
			test3=manual
		fi
	fi
	# Test is system-auth file is configured
	if grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth || grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth; then
		test1=passed
	else
		[ -n "$cpro" ] && file="/etc/authselect/$cpro/system-auth"
		if [ -e "$file" ]; then
			if ! grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file"; then
				if grep -Eqs 'password\s+(requisite|required)\s+pam_pwhistory\.so(\s+[^#]+\s+)?\s*remember=' "$file"; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s+)?(remember=)(\S++\b)(.*)$/\2\4\55 \7/' "$file"
				elif grep -Es 'password\s+(requisite|required)\s+pam_pwhistory\.so' "$file" | grep -vq 'remember='; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s*)?(#.*)?$/\2\4 remember=5\5/' "$file"
				else
					sed -ri '/password\s+(\S+)\s+pam_unix\.so\s+/ i password    required      pam_pwhistory.so remember=5 use_authtok' "$file"
				fi
			fi
			if ! grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file"; then
				if grep -Eqs 'password\s+(requisite|sufficient)\s+pam_unix\.so(\s+[^#]+\s+)?\s*remember=' "$file"; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|sufficient)\s+pam_unix\.so\s+)([^#]+\s+)?(remember=)(\S++\b)(.*)$/\2\4\55 \7/' "$file"
				elif grep -Es 'password\s+(requisite|sufficient)\s+pam_unix\.so' "$file" | grep -vq 'remember='; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|sufficient)\s+pam_unix\.so\s+)([^#]+\s*)?(#.*)?$/\2\4 remember=5\5/' "$file"
				else
					sed -ri '/password\s+(\S+)\s+pam_deny\.so\s+/ i password    required      pam_unix.so remember=5 use_authtok' "$file"
				fi
			fi
		fi
	fi
	# Test is password-auth file is configured
	if grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/password-auth || grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/password-auth; then
		test2=passed
	else
		[ -n "$cpro" ] && file="/etc/authselect/$cpro/password-auth"
		if [ -e "$file" ]; then
			if ! grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file"; then
				if grep -Eqs 'password\s+(requisite|required)\s+pam_pwhistory\.so(\s+[^#]+\s+)?\s*remember=' "$file"; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s+)?(remember=)(\S++\b)(.*)$/\2\4\55 \7/' "$file"
				elif grep -Es 'password\s+(requisite|required)\s+pam_pwhistory\.so' "$file" | grep -vq 'remember='; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|required)\s+pam_pwhistory\.so\s+)([^#]+\s*)?(#.*)?$/\2\4 remember=5\5/' "$file"
				else
					sed -ri '/password\s+(requisite|sufficient)\s+pam_unix\.so\s+.*$/ i password    required      pam_pwhistory.so remember=5 use_authtok' "$file"
				fi
			fi
			if ! grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' "$file"; then
				if grep -Eqs 'password\s+(requisite|sufficient)\s+pam_unix\.so(\s+[^#]+\s+)?\s*remember=' "$file"; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|sufficient)\s+pam_unix\.so\s+)([^#]+\s+)?(remember=)(\S++\b)(.*)$/\2\4\55 \7/' "$file"
				elif grep -Es 'password\s+(requisite|sufficient)\s+pam_unix\.so' "$file" | grep -vq 'remember='; then
					sed -ri 's/^\s*(#\s*)?(password\s+(requisite|sufficient)\s+pam_unix\.so\s+)([^#]+\s*)?(#.*)?$/\2\4 remember=5\5/' "$file"
				else
					sed -ri '/password\s+(required|requisite|sufficient)\s+pam_deny\.so\s+.*$/ i "password    required      pam_unix.so remember=5 use_authtok"' "$file"
				fi
			fi
		fi
	fi
	# Test if recommendation is passed, remediated, manual, or failed remediation
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		if [ "$test3" = manual ]; then
			test=manual
		else
			[ -n "$cpro" ] && authselect apply-changes
			if grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth || grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth; then
				test1=remediated
			fi
			if grep -Eqs '^\s*password\s+(requisite|sufficient)\s+pam_unix\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/password-auth || grep -Eqs '^\s*password\s+(requisite|required)\s+pam_pwhistory\.so\s+([^#]+\s+)?remember=([5-9]|[1-9][0-9]+)\b' /etc/pam.d/system-auth; then
				test2=remediated
			fi
			[ "$test1" = remediated ] && [ "$test2" = remediated ] && test=remediated
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