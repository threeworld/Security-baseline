#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_system_administrator_actions_sudolog_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    Recommendation "Ensure system administrator actions (sudolog) are collected"
# 
ensure_system_administrator_actions_sudolog_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" t1="" t2=""

	# Set sudoers logfile location
	logfile="$(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//' | tr -d \")"

	if [ -n $logfile ]; then
		XCCDF_VALUE_REGEX="^\s*-w\s+$logfile\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		auditctl -l | grep -Eqs "$XCCDF_VALUE_REGEX" && t1=passed
		# Check rules files for rule
		grep -Eqs "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/* && t2=passed || echo "-w $logfile -p wa -k actions" >> /etc/audit/rules.d/50-actions.rules
		# Check if remediation is required
		if [ "$t1" = passed ] && [ "$t2" = passed ]; then
			test=passed
		else
			# re-start auditd
			service auditd restart
			sleep 10
			#re-check for rules
			t1="" t2=""
			# Check running auditd config for rule
			auditctl -l | grep -Eqs "$XCCDF_VALUE_REGEX" && t1=passed
			# Check rules files for rule
			grep -Eqs "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/* && t2=passed
			# Test to see if remediation was successful
			[ "$t1" = passed ] && [ "$t2" = passed ] && test=remediated
		fi
	else
		test=manual
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