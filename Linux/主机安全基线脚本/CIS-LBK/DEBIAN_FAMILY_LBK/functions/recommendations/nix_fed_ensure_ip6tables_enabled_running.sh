#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_ip6tables_enabled_running.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/06/20    Recommendation "Ensure ip6tables is enabled and running"
# 
fed_ensure_ip6tables_enabled_running()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$FWIN" != "IPt" ] || [ "$no_ipv6" = yes ]; then
		test=NA
	else
		if systemctl is-enabled ip6tables | grep -q 'enabled'; then
			test1=passed
		else
			systemctl --now enable ip6tables
			systemctl is-enabled ip6tables | grep -q 'enabled' && test1=remediated
		fi
		if systemctl status ip6tables | grep -Eq "\s+Active:\s+active\s+(\(running\)|\(exited\))\b"; then
			test2=passed
		else
			systemctl --now enable ip6tables
			systemctl status ip6tables | grep -Eq "\s+Active:\s+active\s+(\(running\)|\(exited\))\b" && test=remediated
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
			echo "Recommendation \"$RNA\" Another Firewall is in use on the system or IPv6 is disabled - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}