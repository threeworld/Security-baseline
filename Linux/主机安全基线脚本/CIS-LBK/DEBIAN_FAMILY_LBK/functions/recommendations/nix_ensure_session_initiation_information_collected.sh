#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_session_initiation_information_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure session initiation information is collected"
# 
ensure_session_initiation_information_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" t1="" t2="" t3="" t4="" t5="" t6=""

	# Check rule "-w /var/run/utmp -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/utmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/rules.d/50-session.rules

	# Check rule "-w /var/log/wtmp -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/wtmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t3=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t4=passed || echo "-w /var/log/wtmp -p wa -k logins" >> /etc/audit/rules.d/50-session.rules

	# Check rule "-w /var/log/btmp -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/btmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t5=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t6=passed || echo "-w /var/log/btmp -p wa -k logins" >> /etc/audit/rules.d/50-session.rules

	# Check results of checks
	if [ "$t1" = passed ] && [ "$t2" = passed ] && [ "$t3" = passed ] && [ "$t4" = passed ] && [ "$t5" = passed ] && [ "$t6" = passed ]; then
		test=passed
	else
		# restart the auditd service
		service auditd restart

		# Check rule "-w /var/run/utmp -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/utmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=remediated
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=remediated
		
		# Check rule "-w /var/log/wtmp -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/wtmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t3=remediated
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t4=remediated
		
		# Check rule "-w /var/log/btmp -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/btmp\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t5=remediated
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t6=remediated

		# Test to see if remediation was successful
		[ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ] && [ -n "$t4" ] && [ -n "$t5" ] && [ -n "$t6" ] && test=remediated
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