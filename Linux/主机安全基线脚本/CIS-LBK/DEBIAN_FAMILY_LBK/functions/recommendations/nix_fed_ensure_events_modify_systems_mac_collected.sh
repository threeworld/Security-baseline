#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_events_modify_systems_mac_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/05/20    Recommendation "Ensure events that modify the system's Mandatory Access Controls are collected"
# 
fed_ensure_events_modify_systems_mac_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" t1="" t2=""

	# Check rule "-w /etc/selinux/ -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/selinux\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/50-MAC-policy.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
	t1="" t2=""

	# Check rule "-w /usr/share/selinux/ -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/usr\/share/selinux\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /usr/share/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/50-MAC-policy.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""

	# Check results of checks
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		# re-start auditd
		service auditd restart
		sleep 10
		#re-check for rules

		# Check rule "-w /etc/selinux/ -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/selinux\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule remediated
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
		t1="" t2=""

		# Check rule "-w /usr/share/selinux/ -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/usr\/share/selinux\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule remediated
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""
	fi

	# Check to see test status
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