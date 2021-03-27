#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_login_logout_events_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure login and logout events are collected"
# 
fed_ensure_login_logout_events_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3=""

	tally_chk()
	{
		# Check which account lockout methiod is used

		# Check if pam_faillock is used
		t1="" t2=""
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_faillock\.so\b' /etc/pam.d/system-auth && grep -Eqs '^\s*account\s+required\s+pam_faillock\.so\b' /etc/pam.d/system-auth && t1=pass
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_faillock\.so\b' /etc/pam.d/password-auth && grep -Eqs '^\s*account\s+required\s+pam_faillock\.so\b' /etc/pam.d/password-auth && t2=pass
		if [ "$t1" = pass ] && [ "$t2" = pass ]; then
			faillock=yes
			echo "pam_faillock is used on the system" | tee -a "$LOG" 2>> "$ELOG"
		else
			faillock=no
		fi

		# Check if pam_tally2 is used
		t1="" t2=""
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/system-auth && grep -Eqs '^\s*account\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/system-auth && t1=pass
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/password-auth && grep -Eqs '^\s*account\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/password-auth && t2=pass
		if [ "$t1" = pass ] && [ "$t2" = pass ]; then
			tally2=yes
			echo "pam_tally2 is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
		else
			tally2=no
		fi
		if [ -n "$faillock" ] || [ -n "$tally2" ]; then
			return "${XCCDF_RESULT_PASS:-101}"
		else
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	# Check rule "-w /var/log/faillog -p wa -k {key name}"
	t1="" t2=""
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/faillog\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
	[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed

	# Check rule "-w /var/log/lastlog -p wa -k {key name}"
	t1="" t2=""
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/lastlog\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed

	# Check which pam lockout module is in use on the system
	if [ -z "$faillock" ] && [ -z "$tally2" ]; then
		tally_chk
	fi
	[ "$?" = "101" ] && echo "Check for account lockout methiod successful" | tee -a "$LOG" 2>> "$ELOG" || echo "Check for account lockout methiod failed" | tee -a "$LOG" 2>> "$ELOG"
	# Check for either "-w /var/run/faillock/ -p wa -k {key name}" or "-w /var/log/tallylog -p wa -k {key name}"
	if [ "$faillock" = yes ]; then
		# check rule "-w /var/run/faillock/ -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/faillock\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule 
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-w /var/run/faillock/ -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	elif [ "$tally2" = yes ]; then
		# check rule "-w /var/log/tallylog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/tallylog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule 
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	fi

	# Check results of checks
	if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
		test=passed
	else
		service auditd restart
		sleep 5
		# Check rule "-w /var/log/faillog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/faillog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated

		# Check rule "-w /var/log/lastlog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/lastlog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated

		# Check which pam lockout module is in use on the system
		if [ -z "$faillock" ] && [ -z "$tally2" ]; then
			echo "re-running account lockout methiod check..." | tee -a "$LOG" 2>> "$ELOG"
			tally_chk
		fi
		# Check for either "-w /var/run/faillock/ -p wa -k {key name}" or "-w /var/log/tallylog -p wa -k {key name}"
		if [ "$faillock" = yes ]; then
			# check rule "-w /var/run/faillock/ -p wa -k {key name}"
			t1="" t2=""
			XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/faillock\/?\s+-p\s+wa\s+-k\s+\S+\b"
			# Check running auditd config for rule
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule 
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		elif [ "$tally2" = yes ]; then
			# check rule "-w /var/log/tallylog -p wa -k {key name}"
			t1="" t2=""
			XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/tallylog\/?\s+-p\s+wa\s+-k\s+\S+\b"
			# Check running auditd config for rule
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule 
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		fi
	fi
	# Check to see test status
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
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