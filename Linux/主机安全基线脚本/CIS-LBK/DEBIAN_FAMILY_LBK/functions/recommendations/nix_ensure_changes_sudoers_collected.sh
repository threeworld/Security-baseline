#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_changes_sudoers_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure changes to system administration scope (sudoers) is collected"
# 
ensure_changes_sudoers_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" t1="" t2="" t3="" t4=""
	# Check rule "-w /etc/sudoers -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sudoers\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/rules.d/50-scope.rules
	# Check rule "-w /etc/sudoers.d/ -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sudoers.d\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t3=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t4=passed || echo "-w /etc/sudoers.d/ -p wa -k scope" >> /etc/audit/rules.d/50-scope.rules
	# Check results of checks
	if [ "$t1" = passed ] && [ "$t2" = passed ] && [ "$t3" = passed ] && [ "$t4" = passed ]; then
		test=passed
	else
		service auditd restart
		# Check rule "-w /etc/sudoers -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sudoers\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=remediated
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=remediated
		# Check rule "-w /etc/sudoers.d/ -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sudoers.d\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t3=remediated
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t4=remediated
	fi
	# Check to see test status
	if [ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ] && [ -n "$t4" ]; then
		if [ "$t1" = passed ] && [ "$t2" = passed ] && [ "$t3" = passed ] && [ "$t4" = passed ]; then
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