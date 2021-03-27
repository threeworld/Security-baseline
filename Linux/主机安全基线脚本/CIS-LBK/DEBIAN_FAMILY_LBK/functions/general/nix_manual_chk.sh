#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/general/nix_manual_chk.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/08/20    General "Manual Check Required"
# 
manual_chk()
{
	# Set return code and return
	echo "Recommendation \"$RNA\" Manual remediation required" | tee -a "$LOG" 2>> "$ELOG"
	return "${XCCDF_RESULT_PASS:-106}"
}