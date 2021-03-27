#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_iptables_rules_saved.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/06/20    Recommendation "Ensure iptables rules are saved"
# 
fed_ensure_iptables_rules_saved()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	if [ "$FWIN" != "IPt" ]; then
		test=NA
	else
		if grep -Eqs '^\s*\:INPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables && grep -Eqs '^\s*\:FORWARD\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables && grep -Eqs '^\s*\:OUTPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables; then
			test=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - saving IPTables running configuration to the file /etc/sysconfig/iptables"
			service iptables save
			grep -Eqs '^\s*\:INPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables && grep -Eqs '^\s*\:FORWARD\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables && grep -Eqs '^\s*\:OUTPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/iptables && test=remediated
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