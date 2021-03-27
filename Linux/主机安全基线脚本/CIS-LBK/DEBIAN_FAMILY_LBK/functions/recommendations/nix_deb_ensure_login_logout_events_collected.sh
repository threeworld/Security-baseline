#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_login_logout_events_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/24/20    Recommendation "Ensure login and logout events are collected"
# 
deb_ensure_login_logout_events_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3=""

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