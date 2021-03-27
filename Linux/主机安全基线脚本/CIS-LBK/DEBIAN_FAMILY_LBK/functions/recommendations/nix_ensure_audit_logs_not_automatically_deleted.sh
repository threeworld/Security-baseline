#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_audit_logs_not_automatically_deleted.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure audit logs are not automatically deleted"
# 
ensure_audit_logs_not_automatically_deleted()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if grep -Eqs 'max_log_file_action\s*=\s*keep_logs\b' /etc/audit/auditd.conf; then
		test=passed
	else
		if grep -Eqs '\s*(#+\s*)?max_log_file_action\s*=\s*' /etc/audit/auditd.conf; then
			sed -ri 's/\s*(#+\s*)?(max_log_file_action\s*=\s*)(\S+\s*)?(.*)$/\2keep_logs \4/' /etc/audit/auditd.conf
		else
			echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
		fi
		grep -Eqs 'max_log_file_action\s*=\s*keep_logs\b' /etc/audit/auditd.conf && test=remediated
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