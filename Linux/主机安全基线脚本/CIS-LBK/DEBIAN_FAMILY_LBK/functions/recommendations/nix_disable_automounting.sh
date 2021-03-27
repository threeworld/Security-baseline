#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_disable_automounting.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Disable Automounting"
# 
disable_automounting()
{
	test=""
	if [ -z "$(systemctl is-enabled autofs | grep -i enabled)" ]; then
		test=passed
	else
		systemctl --now mask autofs
		if [ -z "$(systemctl is-enabled autofs | grep -i enabled)" ]; then
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