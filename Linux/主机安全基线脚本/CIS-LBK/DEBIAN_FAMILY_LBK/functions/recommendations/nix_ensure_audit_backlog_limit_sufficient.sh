#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_audit_backlog_limit_sufficient.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/03/20    Recommendation "Ensure audit_backlog_limit is sufficient"
#
ensure_audit_backlog_limit_sufficient()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	[ -s /boot/grub/grub.cfg ] && BDIR="/boot/grub/grub.cfg"
	[ -s /boot/grub2/grub.cfg ] && BDIR="/boot/grub2/grub.cfg"

#	if [ -s /boot/grub2/grub.cfg ];then
#		! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "audit_backlog_limit=" && test=passed
#	elif [ -s /boot/grub/grub.cfg ]; then
#		! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "audit_backlog_limit=" && test=passed
	if ! grep "^\s*linux" "$BDIR" | grep -vq "audit_backlog_limit="; then
		test=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
		sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#"]+\s*)?)(")(.*)$/\1 audit_backlog_limit=8192\3\4/' /etc/default/grub
		grep -Eq '^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?audit_backlog_limit=' /etc/default/grub && sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?)(audit_backlog_limit=\S+\s*)(.*)$/\1\4/' /etc/default/grub
		if [ -s /boot/grub2/grub.cfg ]; then
			grub2-mkconfig -o /boot/grub2/grub.cfg
			! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "audit_backlog_limit=" && test=remediated
		elif [ -s /boot/grub/grub.cfg ]; then
			update-grub
			! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "audit_backlog_limit=" && test=remediated
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
		NA)
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}