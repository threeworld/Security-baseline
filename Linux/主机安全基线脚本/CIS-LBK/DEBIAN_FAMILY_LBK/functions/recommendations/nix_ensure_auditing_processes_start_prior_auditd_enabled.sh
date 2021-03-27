#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_auditing_processes_start_prior_auditd_enabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/03/20    Recommendation "Ensure auditing for processes that start prior to auditd is enabled"
#
ensure_auditing_processes_start_prior_auditd_enabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	[ -s /boot/grub/grub.cfg ] && BDIR="/boot/grub/grub.cfg"
	[ -s /boot/grub2/grub.cfg ] && BDIR="/boot/grub2/grub.cfg"

#	if [ -s /boot/grub2/grub.cfg ];then
#		! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "audit=1" && test=passed
#	elif [ -s /boot/grub/grub.cfg ]; then
#		! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "audit=1" && test=passed
	if ! grep "^\s*linux" "$BDIR" | grep -vq "audit=1"; then
		test=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
#		if grep -s "^\s*linux" /boot/grub/grub.cfg | grep -Eq "audit=" || grep -s "^\s*linux" /boot/grub2/grub.cfg | grep -Eq "audit="; then
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX="([^#]+\s+)?audit=' /etc/default/grub; then
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#]+\s+)?)(audit=\S+\s*)(.*)$/\1audit=1\4/' /etc/default/grub
		else
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#"]+\s*)?)(")(.*)$/\1 audit=1\3\4/' /etc/default/grub
		fi
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?audit=' /etc/default/grub; then
			sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?)(audit=\S+\s*)(.*)$/\1\4/' /etc/default/grub
		fi
#		fi
		if [ -s /boot/grub2/grub.cfg ]; then
			grub2-mkconfig -o /boot/grub2/grub.cfg
			! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "audit=1" && test=remediated
		elif [ -s /boot/grub/grub.cfg ]; then
			update-grub
			! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "audit=1" && test=remediated
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