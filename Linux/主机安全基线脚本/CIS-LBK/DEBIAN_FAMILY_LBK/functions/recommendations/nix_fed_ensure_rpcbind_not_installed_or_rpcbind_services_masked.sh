#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_rpcbind_not_installed_or_rpcbind_services_masked.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/03/20    Recommendation "Ensure rpcbind is not installed or the rpcbind services are masked"
#
fed_ensure_rpcbind_not_installed_or_rpcbind_services_masked()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	if ! $PQ rpcbind >/dev/null; then
		test=passed
	elif systemctl is-enabled rpcbind | grep -q 'masked' && systemctl is-enabled rpcbind.socket | grep -q 'masked'; then
		test=passed
	else
		systemctl is-enabled rpcbind.socket | grep -Eq '(enabled|disabled|masked)' && systemctl --now mask rpcbind.socket
		systemctl is-enabled rpcbind | grep -Eq '(enabled|disabled|masked)' && systemctl --now mask rpcbind
		if ! $PQ rpcbind >/dev/null; then
			test=remediated
		elif systemctl is-enabled rpcbind | grep -q 'masked' && systemctl is-enabled rpcbind.socket | grep -q 'masked'; then
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