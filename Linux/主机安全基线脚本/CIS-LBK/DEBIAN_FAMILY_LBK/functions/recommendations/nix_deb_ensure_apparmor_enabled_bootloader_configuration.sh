#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_apparmor_enabled_bootloader_configuration.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/25/20    Recommendation "Ensure AppArmor is enabled in the bootloader configuration"
#
deb_ensure_apparmor_enabled_bootloader_configuration()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	[ -s /boot/grub/grub.cfg ] && BDIR="/boot/grub/grub.cfg"
	[ -s /boot/grub2/grub.cfg ] && BDIR="/boot/grub2/grub.cfg"

#	if [ -s /boot/grub2/grub.cfg ];then
#		! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "apparmor=1" && test=passed
#	elif [ -s /boot/grub/grub.cfg ]; then
#		! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "apparmor=1" && test=passed
	if ! grep "^\s*linux" "$BDIR" | grep -vq "apparmor=1"; then
		test1=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
#		if grep -s "^\s*linux" /boot/grub/grub.cfg | grep -Eq "apparmor=" || grep -s "^\s*linux" /boot/grub2/grub.cfg | grep -Eq "apparmor="; then
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX="([^#]+\s+)?apparmor=' /etc/default/grub; then
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#]+\s+)?)(apparmor=\S+\s*)(.*)$/\1apparmor=1\4/' /etc/default/grub
		else
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#"]+\s*)?)(")(.*)$/\1 apparmor=1\3\4/' /etc/default/grub
		fi
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?apparmor=' /etc/default/grub; then
			sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?)(apparmor=\S+\s*)(.*)$/\1\4/' /etc/default/grub
		fi
#		fi
		if [ -s /boot/grub2/grub.cfg ]; then
			grub2-mkconfig -o /boot/grub2/grub.cfg
			! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "apparmor=1" && test1=remediated
		elif [ -s /boot/grub/grub.cfg ]; then
			update-grub
			! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "apparmor=1" && test1=remediated
		fi
	fi

	if ! grep "^\s*linux" "$BDIR" | grep -vq "security=apparmor"; then
		test2=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
#		if grep -s "^\s*linux" /boot/grub/grub.cfg | grep -Eq "apparmor=" || grep -s "^\s*linux" /boot/grub2/grub.cfg | grep -Eq "apparmor="; then
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX="([^#]+\s+)?security=' /etc/default/grub; then
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#]+\s+)?)(security=\S+\s*)(.*)$/\1security=apparmor\4/' /etc/default/grub
		else
			sed -ri 's/^\s*(GRUB_CMDLINE_LINUX="([^#"]+\s*)?)(")(.*)$/\1 security=apparmor\3\4/' /etc/default/grub
		fi
		if grep -Eq '^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?security=' /etc/default/grub; then
			sed -ri 's/(^\s*GRUB_CMDLINE_LINUX_DEFAULT="([^#"]+\s+)?)(security=\S+\s*)(.*)$/\1\4/' /etc/default/grub
		fi
#		fi
		if [ -s /boot/grub2/grub.cfg ]; then
			grub2-mkconfig -o /boot/grub2/grub.cfg
			! grep "^\s*linux" /boot/grub2/grub.cfg | grep -vq "security=apparmor" && test2=remediated
		elif [ -s /boot/grub/grub.cfg ]; then
			update-grub
			! grep "^\s*linux" /boot/grub/grub.cfg | grep -vq "security=apparmor" && test2=remediated
		fi
	fi

	if [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
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