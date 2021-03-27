#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_ipv6_outbound_and_established_connections_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/20/20    Recommendation "Ensure IPv6 outbound and established connections are configured"
# 
deb_ensure_ipv6_outbound_and_established_connections_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && deb_firewall_chk
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$FWIN" != "IPt" ] || [ "$no_ipv6" = "yes" ]; then
		test=NA
	else
		ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
		ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
		ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
		ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
		ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
		ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
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