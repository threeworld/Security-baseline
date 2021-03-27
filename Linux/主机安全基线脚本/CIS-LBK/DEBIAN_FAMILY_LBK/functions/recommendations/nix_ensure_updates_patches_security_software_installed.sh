#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_updates_patches_security_software_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/26/20    Recommendation "Ensure updates, patches, and additional security software are installed"
# 
ensure_updates_patches_security_software_installed()
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