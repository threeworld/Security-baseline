#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_system_disabled_audit_logs_full.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure system is disabled when audit logs are full"
# 
ensure_system_disabled_audit_logs_full()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	test3=""
	# Check space_left_action
	if grep -Eqs 'space_left_action\s*=\s*email\b' /etc/audit/auditd.conf; then
		test1=passed
	else
		if grep -Eqs '\s*(#+\s*)?space_left_action\s*=\s*' /etc/audit/auditd.conf; then
			sed -ri 's/\s*(#+\s*)?(space_left_action\s*=\s*)(\S+\s*)?(.*)$/\2email \4/' /etc/audit/auditd.conf
		else
			echo "space_left_action = email" >> /etc/audit/auditd.conf
		fi
		grep -Eqs 'space_left_action\s*=\s*email\b' /etc/audit/auditd.conf && test1=remediated
	fi
	# Check action_mail_acct
	if grep -Eqs 'action_mail_acct\s*=\s*root\b' /etc/audit/auditd.conf; then
		test2=passed
	else
		if grep -Eqs '\s*(#+\s*)?action_mail_acct\s*=\s*' /etc/audit/auditd.conf; then
			sed -ri 's/\s*(#+\s*)?(action_mail_acct\s*=\s*)(\S+\s*)?(.*)$/\2root \4/' /etc/audit/auditd.conf
		else
			echo "action_mail_acct = root" >> /etc/audit/auditd.conf
		fi
		grep -Eqs 'action_mail_acct\s*=\s*root\b' /etc/audit/auditd.conf && test2=remediated
	fi
	# Check admin_space_left_action
	if grep -Eqs 'admin_space_left_action\s*=\s*halt\b' /etc/audit/auditd.conf; then
		test3=passed
	else
		if grep -Eqs '\s*(#+\s*)?admin_space_left_action\s*=\s*' /etc/audit/auditd.conf; then
			sed -ri 's/\s*(#+\s*)?(admin_space_left_action\s*=\s*)(\S+\s*)?(.*)$/\2halt \4/' /etc/audit/auditd.conf
		else
			echo "admin_space_left_action = halt" >> /etc/audit/auditd.conf
		fi
		grep -Eqs 'admin_space_left_action\s*=\s*halt\b' /etc/audit/auditd.conf && test3=remediated
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