#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_tmp_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/08/20    Recommendation "Ensure /tmp is configured"
# 
ensure_tmp_configured()
{
	test=""	test1=""
	tmp_chk()
	{
		test1=""
		if mount | grep -Eq '\s\/tmp\b'; then
			if grep -Eq '^\s*[^#]+\s+\/tmp\/?\s' /etc/fstab || systemctl is-enabled tmp.mount | grep -q 'enabled'; then
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
		if ! grep -Eq '^\s*[^#]+\s+\/tmp\/?\s' /etc/fstab; then
			echo "# Added by CIS Linux Build Kit" >> /etc/fstab
			echo "tmpfs   /tmp    tmpfs   defaults,noexec,nosuid,nodev 0   0" >> /etc/fstab
		fi
		if ! mount | grep -Eq '\s\/tmp\b'; then
			mount /tmp
		else
			mount -o remount,noexec,nodev,nosuid /tmp
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