#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_audit_backlog_limit_sufficient.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure audit_backlog_limit is sufficient"
# 
fed28_ensure_audit_backlog_limit_sufficient()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if grep -Eqs 'kernelopts=([^#]+\s+)?audit_backlog_limit=\S+\b' /boot/grub2/grubenv; then
		test=passed
	else
		sed -ri 's/\s*(GRUB_CMDLINE_LINUX="[^#"]+)(")(.*)$/\1 audit_backlog_limit=8192\2\3/' /etc/default/grub
		grub2-mkconfig -o /boot/grub2/grub.cfg
		grep -Eqs 'kernelopts=([^#]+\s+)?audit_backlog_limit=\S+\b' /boot/grub2/grubenv && test=remediated
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