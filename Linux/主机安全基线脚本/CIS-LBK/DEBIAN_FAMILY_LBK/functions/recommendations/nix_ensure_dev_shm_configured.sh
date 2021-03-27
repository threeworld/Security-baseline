#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_dev_shm_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/08/20    Recommendation "Ensure /dev/shm is configured"
# Eric Pinnell       11/10/20    Modified "Corrected bug in remediation"
# 
ensure_dev_shm_configured()
{
	test=""	test1=""
	tmp_chk()
	{
		test1=""
		if mount | grep -Eq '\s\/dev\/shm\/?\b'; then
			if grep -Eq '^\s*[^#]+\s+\/dev\/shm\/?\s' /etc/fstab; then
				test1=passed
			fi
		fi
	}
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	# Check and if nessassary remediate if /tmp is configured
	tmp_chk
	if [ "$test1" = passed ]; then
		test=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
		if ! grep -Eq '^\s*[^#]+\s+\/dev\/shm\/?\s' /etc/fstab; then
			echo "# Added by CIS Linux Build Kit" >> /etc/fstab
			echo "tmpfs      /dev/shm    tmpfs   defaults,noexec,nodev,nosuid,seclabel   0 0" >> /etc/fstab
		fi
		if ! mount | grep -Eq '\s\/dev\/shm\b'; then
			mount /dev/shm
		else
			mount -o remount,noexec,nodev,nosuid /dev/shm
		fi
		tmp_chk
		[ "$test1" = passed ] && test=remediated
	fi
	echo "- $(date +%d-%b-%Y' '%T) - Completed $RNA" | tee -a "$LOG" 2>> "$ELOG"
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