#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_events_modify_user_group_information_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/05/20    Recommendation "Ensure events that modify user/group information are collected"
# 
ensure_events_modify_user_group_information_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""  test3=""  test4="" test5="" t1="" t2=""

	# Check rule "-w /etc/group -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/group\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/50-identity.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
	t1="" t2=""

	# Check rule "-w /etc/passwd -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/passwd\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/50-identity.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""


	# Check rule "-w /etc/gshadow -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/gshadow\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/rules.d/50-identity.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	t1="" t2=""

	# Check rule "-w /etc/shadow -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/shadow\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/50-identity.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test4=passed
	t1="" t2=""

	# Check rule "-w /etc/security/opasswd -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/security\/opasswd\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/rules.d/50-identity.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test5=passed
	t1="" t2=""

	# Check results of checks
	if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ]; then
		test=passed
	else
		# re-start auditd
		service auditd restart
		sleep 10
		#re-check for rules

		# Check rule "-w /etc/group -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/group\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
		t1="" t2=""

		# Check rule "-w /etc/passwd -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/passwd\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""


		# Check rule "-w /etc/gshadow -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/gshadow\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		t1="" t2=""

		# Check rule "-w /etc/shadow -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/shadow\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test4=remediated
		t1="" t2=""

		# Check rule "-w /etc/security/opasswd -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/security\/opasswd\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test5=remediated
		t1="" t2=""
	fi

	# Check to see test status
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ] && [ -n "$test5" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ -n "$test3" ] && [ -n "$test4" ] && [ -n "$test5" ]; then
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