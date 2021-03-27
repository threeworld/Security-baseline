#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_ipv4_outbound_and_established_connections_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/08/20    Recommendation "Ensure outbound and established connections are configured"
# 
ensure_ipv4_outbound_and_established_connections_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	if [ "$FWIN" != "IPt" ]; then
		test=NA
	else
		iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
		iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
		iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
		test=manual
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