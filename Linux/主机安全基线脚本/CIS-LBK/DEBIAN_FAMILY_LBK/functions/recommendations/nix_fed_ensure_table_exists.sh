#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_table_exists.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/07/20    Recommendation "Ensure a table exists"
# 
fed_ensure_table_exists()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	create_nft_rule_file()
	{
		echo '#!/sbin/nft -f' > /etc/nftables/cis_nftables.rules
		{
			echo '# This nftables.rules config should be saved as /etc/nftables/nftables.rules'
			echo '# flush nftables rulesset'
			echo 'flush ruleset'
			echo ""
			echo '# Load nftables ruleset'
			echo ""
			echo '# nftables config with inset table named filter'
			echo
			echo 'table inet filter {'
			echo '   # Base chain for input hook named input (Filters inbound network packets'
			echo '   chain input {'
			echo '      type filter hook input priority 0; policy drop;'
			echo ""
			echo '      # Ensure loopback traffic is configured'
            echo '      iif "lo" accept'
            echo '      ip saddr 127.0.0.0/8 counter packets 0 bytes 0 drop'
            echo '      ip6 saddr ::1 counter packets 0 bytes 0 drop'
            echo ""
            echo '      # Ensure established connections are configured'
            echo '      ip protocol tcp ct state established accept'
            echo '      ip protocol udp ct state established accept'
            echo '      ip protocol icmp ct state established accept'
            echo ""
            echo '      # Accept port 22(SSH) traffic from anywhere'
            echo '      tcp dport ssh accept'
            echo ""
            echo '      # Accept ICMP and IGMP from anywhere'
            echo '      icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-done, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert, mld2-listener-report } accept'
			echo '      icmp type { destination-unreachable, router-advertisement, router-solicitation, time-exceeded, parameter-problem } accept'
			echo '      ip protocol igmp accept'
			echo '   }'
			echo ""
			echo '   # Base chain for hook forward named forward (Filters forwarded network packets)'
			echo '   chain forward {'
			echo '      type filter hook forward priority 0; policy drop;'
			echo '   }'
			echo ""
			echo '   # Base chain for hook output named output (Filters outbount network packets)'
			echo '   chain output {'
			echo '      type filter hook output priority 0; policy drop;'
			echo '      # Ensure outbound and established connections are configured'
			echo '      ip protocol tcp ct state established,related,new accept'
			echo '      ip protocol udp ct state established,related,new accept'
			echo '      ip protocol icmp ct state established,related,new accept'
			echo '   }'
			echo '}'
		} >> /etc/nftables/cis_nftables.rules
		# Load the created file into nftables
		nft -f /etc/nftables/cis_nftables.rules
		# Update to make the rules file active on boot
		echo "include \"/etc/nftables/cis_nftables.rules\"" >> /etc/sysconfig/nftables.conf
	}
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
			if nft list tables | grep -Eqs '^table\s+\S+\s+\S+\b'; then
				test=passed
			else
#				# Create a table in NFTables
#				nft create table inet filter
				# No NFTables table exists, create and load NFTables rules file /etc/nftables/cis_nftables.rules
				create_nft_rule_file
				# Test if remediation was successful
				nft list tables | grep -Eqs '^table\s+\S+\s+\S+\b' && test=remediated
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