#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendation/nix_ensure_selinux_not_disabled_bootloader_configuration.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/29/20    Recommendation "Ensure SELinux is not disabled in bootloader configuration"
#
ensure_selinux_not_disabled_bootloader_configuration()
{

	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if [ -s /boot/grub2/grub.cfg ];then
		! grep "^\s*linux" /boot/grub2/grub.cfg | grep -Eq "(selinux=0|enforcing=0)" && test=passed
	elif [ -s /boot/grub/grub.cfg ]; then
		! grep "^\s*linux" /boot/grub/grub.cfg | grep -Eq "(selinux=0|enforcing=0)" && test=passed
	else
		if grep "^\s*linux" /boot/grub/grub.cfg | grep -Eq "selinux=0"; then
			echo "- $(date +%d-%b-%Y' '%T) - SELinux is disabled.  Enabling SELinux will cause a re-label of all files on the system.  Please schedule appropriate down-time.  Because of the possibility of extended system downtime, this is a manual remediation" | tee -a "$LOG" 2>> "$ELOG"
			test=manual
		else
	#		sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT=")([^#]+\s+)?(selinux=0\s*)(.*)?/\1\2\4/' /etc/default/grub
	#		sed -ri 's/(^\s*GRUB_CMDLINE_LINUX=")([^#]+\s+)?(selinux=0\s*)(.*)?/\1\2\4/' /etc/default/grub
			sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT=")([^#]+\s+)?(enforcing=0\s*)(.*)?/\1\2\4/' /etc/default/grub
			sed -ri 's/(^\s*GRUB_CMDLINE_LINUX=")([^#]+\s+)?(enforcing=0\s*)(.*)?/\1\2\4/' /etc/default/grub
			if [ -s /boot/grub2/grub.cfg ];then
				grub2-mkconfig -o /boot/grub2/grub.cfg
				! grep "^\s*linux" /boot/grub2/grub.cfg | grep -Eq "(selinux=0|enforcing=0)" && test=remediated
			elif [ -s /boot/grub/grub.cfg ]; then
				update-grub
				! grep "^\s*linux" /boot/grub/grub.cfg | grep -Eq "(selinux=0|enforcing=0)" && test=remediated
			fi
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