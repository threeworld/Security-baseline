#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_package_manager_repositories_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure package manager repositories are configured"
# 
ensure_package_manager_repositories_configured()
{
	passing=""
	manual_chk
	[ "$?" = "106" ] && passing=true
	# Set return code and return
	if [ "$passing" = true ]; then
		echo "Recommendation \"$RNA\" requires manual remediation" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-106}"
	else
		echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}