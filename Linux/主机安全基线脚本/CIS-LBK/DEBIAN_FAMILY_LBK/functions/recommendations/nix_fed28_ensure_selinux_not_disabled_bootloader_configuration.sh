#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_selinux_not_disabled_bootloader_configuration.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/24/20    Recommendation "Ensure SELinux is not disabled in bootloader configuration"
# 
fed28_ensure_selinux_not_disabled_bootloader_configuration()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if ! grep -Eqs 'kernelopts=([^#]+\s+)?(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv; then
		test=passed
	else
		if grep -Eqs 'kernelopts=([^#]+\s+)?(selinux=0)+\b' /boot/grub2/grubenv; then
			echo "- $(date +%d-%b-%Y' '%T) - Enabling SELinux will force a re-lable of all files.  This may take a long time" | tee -a "$LOG" 2>> "$ELOG" 
			echo "- $(date +%d-%b-%Y' '%T) - Schedual approprate down time and manually apply this recommendation" | tee -a "$LOG" 2>> "$ELOG"
			test=manual
		fi
		if grep -Eqs 'kernelopts=([^#]+\s+)?(enforcing=0)+\b' /boot/grub2/grubenv; then
	#		sed -ri 's/selinux=0\s*//' /etc/default/grub
			sed -ri 's/enforcing=0\s*//' /etc/default/grub
			grub2-mkconfig -o /boot/grub2/grub.cfg
			! grep -Eqs 'kernelopts=([^#]+\s+)?(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv && test=remediated
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