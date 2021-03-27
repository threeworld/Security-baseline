#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_outbound_established_connections_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/07/20    Recommendation "Ensure outbound and established connections are configured"
# 
fed_ensure_outbound_established_connections_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && fed_firewall_chk
	if [ "$FWIN" != "NFt" ]; then
		test=NA
	else
		# Check is package manager is defined
		if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
			nix_package_manager_set
		fi
		if ! $PQ nftables; then
			test=manual
		else
			# Manual Remediation required
			# Adding base accept policy for usability
			if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
				nft add rule inet filter input ip protocol tcp ct state established accept
				nft add rule inet filter input ip protocol udp ct state established accept
				nft add rule inet filter input ip protocol icmp ct state established accept
				nft add rule inet filter output ip protocol tcp ct state new,related,established accept
				nft add rule inet filter output ip protocol udp ct state new,related,established accept
				nft add rule inet filter output ip protocol icmp ct state new,related,established accept
			else
				# Create table inet filter and add base accept rules
				nft create table inet filter
				nft add rule inet filter input ip protocol tcp ct state established accept
				nft add rule inet filter input ip protocol udp ct state established accept
				nft add rule inet filter input ip protocol icmp ct state established accept
				nft add rule inet filter output ip protocol tcp ct state new,related,established accept
				nft add rule inet filter output ip protocol udp ct state new,related,established accept
				nft add rule inet filter output ip protocol icmp ct state new,related,established accept
			fi
			test=manual
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