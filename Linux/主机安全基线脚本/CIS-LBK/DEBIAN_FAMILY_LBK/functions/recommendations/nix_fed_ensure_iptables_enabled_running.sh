#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_iptables_enabled_running.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/06/20    Recommendation "Ensure iptables is enabled and running"
# 
fed_ensure_iptables_enabled_running()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	if [ "$FWIN" != "IPt" ]; then
		test=NA
	else
		if systemctl is-enabled iptables | grep -q 'enabled'; then
			test1=passed
		else
			systemctl --now enable iptables
			systemctl is-enabled iptables | grep -q 'enabled' && test1=remediated
		fi
		if systemctl status iptables | grep -Eq "\s+Active:\s+active\s+(\(running\)|\(exited\))"; then
			test2=passed
		else
			systemctl --now enable iptables
			systemctl status iptables | grep -Eq "\s+Active:\s+active\s+(\(running\)|\(exited\))" && test2=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ]; then
				test=passed
			else
				test=remediated
			fi
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
			echo "Recommendation \"$RNA\" Another Firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}