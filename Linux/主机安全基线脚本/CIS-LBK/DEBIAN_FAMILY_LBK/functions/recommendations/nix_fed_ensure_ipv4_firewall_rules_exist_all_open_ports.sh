#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_ipv4_firewall_rules_exist_all_open_ports.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/08/20    Recommendation "Ensure firewall rules exist for all open ports"
# 
fed_ensure_ipv4_firewall_rules_exist_all_open_ports()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	if [ "$FWIN" != "IPt" ]; then
		test=NA
	else
		# Check if rule exists
		port_configured_tst()
		{
			ss -4Hln | awk '{ split($5,a,":"); print $1 " " a[2]}' | while read -r pcall pnum; do
				! iptables -L INPUT -v -n | grep -Eq "($pcall|all).*(dpt|dports)[:\s,]$pnum\b" && return "${XCCDF_RESULT_FAIL:-102}"
			done
		}
		port_configured_fix()
		{
			ss -4Hln | awk '{ split($5,a,":"); print $1 " " a[2]}' | while read -r pcall pnum; do
				if ! iptables -L INPUT -v -n | grep -Eq "($pcall|all).*(dpt|dports)[:\s,]$pnum\b"; then
					# Open the port for listening ports in the firewall
					iptables -A INPUT -p "$pcall" --dport "$pnum" -m state --state NEW -j ACCEPT
				fi
			done
		}
		port_configured_tst
		if [ "$?" != "102" ]; then
			test=passed
		else
			port_configured_fix
			port_configured_tst
			[ "$?" != "102" ] && test=remediated
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