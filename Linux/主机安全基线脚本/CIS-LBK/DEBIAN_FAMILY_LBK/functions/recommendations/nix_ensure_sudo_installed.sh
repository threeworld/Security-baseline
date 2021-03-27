#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_sudo_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure sudo is installed"
# 
ensure_sudo_installed()
{
	test=""
	# Set package manager information
	if [ -z "$PM" ] || [ -z "$PQ" ]; then
		nix_package_manager_set
	fi
	# Check is sudo is installed
	if $PQ sudo | grep -Eq 'sudo-\S+'; then
		test=passed
	else
		$PM -y install sudo
		$PQ sudo | grep -Eq 'sudo-\S+' && test=remediated
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