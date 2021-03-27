#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_dccp_disabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/18/20    Recommendation "Ensure DCCP is disabled"
#
ensure_dccp_disabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""

	if modprobe -n -v dccp | grep -Eq "^\s*install\s+\/bin\/(true|false)\b"; then
		test1=passed
	else
		echo "install dccp /bin/true" >> /etc/modprobe.d/dccp.conf
		modprobe -n -v dccp | grep -Eq "^\s*install\s+\/bin\/(true|false)\b" && test1=remediated
	fi

	if ! lsmod | grep -Eq "^\s*dccp\b"; then
		test2=passed
	else
		rmmod dccp
		! lsmod | grep -Eq "^\s*dccp\b" && test2=remediatet
	fi

	if [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi

	# Set return code and return
	case "$test" in
		passed)
			echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo "Recommendation \"$RNA\" requires manual remediation" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		NA)
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}