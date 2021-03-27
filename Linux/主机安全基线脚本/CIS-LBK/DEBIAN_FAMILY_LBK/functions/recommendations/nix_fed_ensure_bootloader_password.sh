#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_bootloader_password.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/16/20    Recommendation "Ensure bootloader password is set"
# 
fed_ensure_bootloader_password()
{
	test=""
	if [ -e /boot/grub2/user.cfg ]; then
		grep -Eq '^\s*GRUB2_PASSWORD=\S+' /boot/grub2/user.cfg && test=passed
	elif grep -q '^\s*set superusers' /boot/grub2/grub.cfg && grep -q "^\s*password" /boot/grub2/grub.cfg; then
		test=passed
	fi
	# Set return code and return
	if [ "$test" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	else
		echo "Recommendation \"$RNA\" Manual remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-106}"
	fi
}