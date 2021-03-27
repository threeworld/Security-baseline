#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_root_only_uid_0.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      09/25/20    Recommendation "Ensure root is the only UID 0 account"

root_only_uid_0_fct()
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