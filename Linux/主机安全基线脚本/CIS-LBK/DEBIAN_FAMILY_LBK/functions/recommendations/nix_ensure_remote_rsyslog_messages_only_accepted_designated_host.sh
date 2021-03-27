#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_remote_rsyslog_messages_only_accepted_designated_host.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure remote rsyslog messages are only accepted on designated log hosts"
# 
ensure_remote_rsyslog_messages_only_accepted_designated_host()
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