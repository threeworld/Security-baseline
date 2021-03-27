#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_auditing_processes_start_prior_auditd_enabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure auditing for processes that start prior to auditd is enabled"
# 
fed28_ensure_auditing_processes_start_prior_auditd_enabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if grep -Eqs 'kernelopts=([^#]+\s+)?audit=1\b' /boot/grub2/grubenv; then
		test=passed
	else
		if grep -Eqs '\s*audit=\S+\s*' /etc/default/grub; then
			sed -ri 's/\s*audit=\S+\s*/ audit=1 /' /etc/default/grub
		else
			sed -ri 's/\s*(GRUB_CMDLINE_LINUX="[^#"]+)(")(.*)$/\1 audit=1\2\3/' /etc/default/grub
		fi
		grub2-mkconfig -o /boot/grub2/grub.cfg
		grep -Eqs 'kernelopts=([^#]+\s+)?audit=1\b' /boot/grub2/grubenv && test=remediated
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