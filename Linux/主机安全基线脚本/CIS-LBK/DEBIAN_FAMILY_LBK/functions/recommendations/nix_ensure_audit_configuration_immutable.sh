#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_audit_configuration_immutable.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    Recommendation "Ensure the audit configuration is immutable"
# 
ensure_audit_configuration_immutable()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	for file in /etc/audit/rules.d/*.rules; do
		tail -1 "$file" | grep -Eqs -- '^\s*-e\s2\b' && test=passed
	done
	if [ "$test" != passed ]; then
		echo "-e 2" >> /etc/audit/rules.d/99-finalize.rules
		# re-start auditd
		service auditd restart
		# Wait to ensure auditd has re-started fully (Errors may result otherwise)
		sleep 10
		for file in /etc/audit/rules.d/*.rules; do
			tail -1 "$file" | grep -Eqs -- '^\s*-e\s2\b' && test=remediated
		done
	fi
	# Set return code and return
	if [ "$test" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	elif [ "$test" = remediated ]; then
		echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-103}"
	else
		echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}