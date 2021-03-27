#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_aide_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/15/20    Recommendation "Ensure AIDE is installed"
# 
ensure_aide_installed()
{
	test=""
	# Set package manager information
	if [ -z "$PM" ] || [ -z "$PQ" ]; then
		nix_package_manager_set
	fi
	# Check is aide is installed
	if $PQ aide | grep -Eq 'aide-\S+'; then
		test=passed
	else
		$PM -y install aide
		echo "Initializing AIDE, this may take a few minutes"
		aide --init
		mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
		$PQ aide | grep -Eq 'aide-\S+' && test=remediated
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