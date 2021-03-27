#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_ip6tables_rules_saved.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/06/20    Recommendation "Ensure ip6tables rules are saved"
# 
fed_ensure_ip6tables_rules_saved()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$FWIN" != "IPt" ] || [ "$no_ipv6" = yes ]; then
		test=NA
	else
		if grep -Eqs '^\s*\:INPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/ip6tables && grep -Eqs '^\s*\:OUTPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/ip6tables; then
			test=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - saving IP6Tables running configuration to the file /etc/sysconfig/ip6tables"
			service ip6tables save
			grep -Eqs '^\s*\:INPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/ip6tables && grep -Eqs '^\s*\:OUTPUT\s+DROP\s+\[\S+\:\S+\]' /etc/sysconfig/ip6tables && test=remediated
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