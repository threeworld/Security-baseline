#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_setroubleshoot_not_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure SETroubleshoot is not installed"
# 
fed_ensure_setroubleshoot_not_installed()
{
	test=""
	# Set package manager information
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check if setroubleshoot is not installed
	if ! $PQ  setroubleshoot 2>>/dev/null; then
		test=passed
	else
		$PR setroubleshoot
		! $PQ  setroubleshoot 2>>/dev/null && test=remediated
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