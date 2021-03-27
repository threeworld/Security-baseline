#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_permissions_bootloader_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/15/20    Recommendation "Ensure permissions on bootloader config are configured"
# 
ensure_permissions_bootloader_configured()
{
	test=""
	test1=""
	test2=""
	test3=""
	test4=""
	GRUBCFG="$(find /boot -type f -name grub.cfg)"
	GRUBENV="$(find /boot -type f -name grubenv)"
	if [ -f "$GRUBCFG" ]; then
		if [ "$(stat -L -c "%U %G" "$GRUBCFG")" = "root root" ]; then
			test1=passed
		else
			chown root:root "$GRUBCFG"
			[ "$(stat -L -c "%U %G" "$GRUBCFG")" = "root root" ] && test1=remediated
		fi
		if [ "$(stat -L -c "%A" "$GRUBCFG" | cut -c4-10)" = "-------" ]; then
			test2=passed
		else
			chmod u-x,go-rwx "$GRUBCFG"
			[ "$(stat -L -c "%A" "$GRUBCFG" | cut -c4-10)" = "-------" ] && test2=remediated
		fi
	fi
	if [ -f "$GRUBENV" ]; then
		if [ "$(stat -L -c "%U %G" "$GRUBENV")" = "root root" ]; then
			test3=passed
		else
			chown root:root "$GRUBENV"
			[ "$(stat -L -c "%U %G" "$GRUBENV")" = "root root" ] && test3=remediated
		fi
		if [ "$(stat -L -c "%A" "$GRUBENV" | cut -c4-10)" = "-------" ]; then
			test4=passed
		else
			chmod u-x,go-rwx "$GRUBENV"
			[ "$(stat -L -c "%A" "$GRUBENV" | cut -c4-10)" = "-------" ] && test4=remediated
		fi
	else
		test3=passed
		test4=passed
	fi
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ]; then
			test=passed
		else
			test=remediated
		fi
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