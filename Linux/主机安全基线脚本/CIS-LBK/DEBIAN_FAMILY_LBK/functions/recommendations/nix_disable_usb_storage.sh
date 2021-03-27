#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_disable_usb_storage.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Disable USB Storage"
# 
disable_usb_storage()
{
	test=""
	test1=""
	test2=""
	# Check if module is disabled
	if modprobe -n -v usb-storage | grep -Eq 'install /bin/(true|false)'; then
		test1=passed
	else
		echo "install usb-storage /bin/true" >> /etc/modprobe.d/usb_storage.conf
		modprobe -n -v usb-storage | grep -Eq 'install /bin/(true|false)' && test1=remediated
	fi
	# check if module is loaded
	if lsmod | grep usb-storage; then
		rmmod usb-storage
		[ -z "$(lsmod | grep usb-storage)" ] && test2=remediated
	else
		test2=passed
	fi
	# check status to set return code
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	elif [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = remediated ] || [ "$test2" = remediated ]; then
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