#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_lockout_failed_password_attempts_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/28/20    Recommendation "Ensure lockout for failed password attempts is configured"
# 
fed28_ensure_lockout_failed_password_attempts_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	test3=""
	test4=""
	test5=""
	test6=""
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
	if grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*deny=[1-5]\b' /etc/pam.d/system-auth; then
		test1=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/system-auth" ]; then
			file="/etc/authselect/$cpro/system-auth"
			if grep -Eqs 'auth\s+\S+\s+pam_faillock\.so\s+(\S+\s+)*deny=' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s+)?(deny=)(\S+\b)(.*)$/\2required\4\5\65\8/' "$file"
			elif grep -Eqs '^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s*)?(#.*)?$/\2required\4\5 deny=5 \6/' "$file"
			else
				sed -ri '/auth\s+(\S+)\s+pam_deny\.so\s*/ i  auth        required                                     pam_faillock.so authfail deny=5 unlock_time=900' "$file"
				sed -ri '/auth\s+(\S+)\s+pam_env\.so\s*/a auth        required                                     pam_faillock.so preauth silent deny=5 unlock_time=900' "$file"
			fi
		fi
	fi
	if grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=(9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b' /etc/pam.d/system-auth; then
		test2=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/system-auth" ]; then
			file="/etc/authselect/$cpro/system-auth"
			if grep -Eqs 'auth\s+\S+\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s+)?(unlock_time=)(\S+\b)(.*)$/\2required\4\5\6900\8/' "$file"
			elif grep -Eqs '^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s*)?(#.*)?$/\2required\4\5 unlock_time=900 \6/' "$file"
			else
				sed -ri '/auth\s+(\S+)\s+pam_deny\.so\s*/ i  auth        required                                     pam_faillock.so authfail deny=5 unlock_time=900' "$file"
				sed -ri '/auth\s+(\S+)\s+pam_env\.so\s*/a auth        required                                     pam_faillock.so preauth silent deny=5 unlock_time=900' "$file"
			fi
		fi
	fi
	if grep -Eqs '^\s*account\s+\S+\s+pam_faillock.so\s*' /etc/pam.d/system-auth; then
		test3=passed
	else
		[ -e "/etc/authselect/$cpro/system-auth" ] && sed -ri '/account\s+(\S+)\s+pam_unix\.so\s*/ i  account     required                                     pam_faillock.so' /etc/authselect/"$cpro"/system-auth
	fi

	# Test is password-auth file is configured
	if grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*deny=[1-5]\b' /etc/pam.d/password-auth; then
		test4=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/password-auth" ]; then
			file="/etc/authselect/$cpro/password-auth"
			if grep -Eqs 'auth\s+\S+\s+pam_faillock\.so\s+(\S+\s+)*deny=' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s+)?(deny=)(\S+\b)(.*)$/\2required\4\5\65\8/' "$file"
			elif grep -Eqs '^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s*)?(#.*)?$/\2required\4\5 deny=5 \6/' "$file"
			else
				sed -ri '/auth\s+(\S+)\s+pam_deny\.so\s*/ i  auth        required                                     pam_faillock.so authfail deny=5 unlock_time=900' "$file"
				sed -ri '/auth\s+(\S+)\s+pam_env\.so\s*/a auth        required                                     pam_faillock.so preauth silent deny=5 unlock_time=900' "$file"
			fi
		fi
	fi
	if grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=(9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b' /etc/pam.d/password-auth; then
		test5=passed
	else
		if [ "$test" != manual ] && [ -e "/etc/authselect/$cpro/password-auth" ]; then
			file="/etc/authselect/$cpro/password-auth"
			if grep -Eqs 'auth\s+\S+\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s+)?(unlock_time=)(\S+\b)(.*)$/\2required\4\5\6900\8/' "$file"
			elif grep -Eqs '^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)' "$file"; then
				sed -ri 's/^\s*(#\s*)?(auth\s+)(\S+)(\s+ pam_faillock\.so\s+)([^#]+\s*)?(#.*)?$/\2required\4\5 unlock_time=900 \6/' "$file"
			else
				sed -ri '/auth\s+(\S+)\s+pam_deny\.so\s*/ i  auth        required                                     pam_faillock.so authfail deny=5 unlock_time=900' "$file"
				sed -ri '/auth\s+(\S+)\s+pam_env\.so\s*/a auth        required                                     pam_faillock.so preauth silent deny=5 unlock_time=900' "$file"
			fi
		fi
	fi
	if grep -Eqs '^\s*account\s+\S+\s+pam_faillock.so\s*' /etc/pam.d/password-auth; then
		test6=passed
	else
		[ -e "/etc/authselect/$cpro/password-auth" ] && sed -ri '/account\s+(\S+)\s+pam_unix\.so\s*/ i  account     required                                     pam_faillock.so' /etc/authselect/"$cpro"/password-auth
	fi	
	# Check for recommendation passing state
	if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && [ "$test6" = passed ]; then
		test=passed
	elif [ "$test" != manual ]; then
		[ -n "$cpro" ] && authselect apply-changes
		grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*deny=[1-5]\b' /etc/pam.d/system-auth && test1=remediated
		grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=(9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b' /etc/pam.d/system-auth && test2=remediated
		grep -Eqs '^\s*account\s+\S+\s+pam_faillock.so\s*' /etc/pam.d/system-auth && test3=remediated
		grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*deny=[1-5]\b' /etc/pam.d/password-auth && test4=remediated
		grep -Eqs '^\s*auth\s+required\s+pam_faillock\.so\s+(\S+\s+)*unlock_time=(9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b' /etc/pam.d/password-auth && test5=remediated
		grep -Eqs '^\s*account\s+\S+\s+pam_faillock.so\s*' /etc/pam.d/password-auth && test6=remediated
		[ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ] && [ -n "$test5" ] && [ -n "$test6" ] && test=remediated
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