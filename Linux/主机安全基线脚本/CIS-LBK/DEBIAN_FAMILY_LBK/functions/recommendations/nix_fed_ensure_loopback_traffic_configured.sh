#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_loopback_traffic_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/07/20    Recommendation "Ensure loopback traffic is configured"
# 
fed_ensure_loopback_traffic_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3=""
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
			# Test for input iif lo accept (test1)
			if nft list ruleset | awk '/hook input/,/}/' | grep -q 'iif "lo" accept'; then
				test1=passed
			else
				if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
					nft add rule inet filter input iif lo accept
					nft list ruleset | awk '/hook input/,/}/' | grep -q 'iif "lo" accept' && test1=remediated
				else
					nft create table inet filter
					nft add rule inet filter input iif lo accept
					nft list ruleset | awk '/hook input/,/}/' | grep -q 'iif "lo" accept' && test1=remediated
				fi
			fi

			# Test for hook forward (test2)
			if nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip\s+saddr\s+127\.0\.0\.0\/8\s+counter\s+packets\s+[^#]+\s+drop\b'; then
				test2=passed
			else
				if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
					nft create rule inet filter input ip saddr 127.0.0.0/8 counter drop
					nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip\s+saddr\s+127\.0\.0\.0\/8\s+counter\s+packets\s+[^#]+\s+drop\b' && test2=remediated
				else
					nft create table inet filter
					nft create rule inet filter input ip saddr 127.0.0.0/8 counter drop
					nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip\s+saddr\s+127\.0\.0\.0\/8\s+counter\s+packets\s+[^#]+\s+drop\b' && test2=remediated
				fi
			fi

			# Test for hook output (test3)
			[ -z "$no_ipv6" ] && ipv6_chk
			if [ "$no_ipv6" != "yes" ]; then
				if nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip6\s+saddr\s+\:\:1\s+counter\s+packets\s+[^#]+\s+drop\b'; then
					test3=passed
				else
					if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
						nft add rule inet filter input ip6 saddr ::1 counter drop
						nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip6\s+saddr\s+\:\:1\s+counter\s+packets\s+[^#]+\s+drop\b' && test3=remediated
					else
						nft create table inet filter
						nft add rule inet filter input ip6 saddr ::1 counter drop
						nft list ruleset | awk '/hook input/,/}/' | grep -Eqs 'ip6\s+saddr\s+\:\:1\s+counter\s+packets\s+[^#]+\s+drop\b' && test3=remediated
					fi
				fi
			else
				test3=passed
			fi
			# Test for status of tests
			if [ -n "$test1" ] && [ -n "$test2" ] && [ "$test3" ]; then
				if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
					test=passed
				else
					test=remediated
				fi
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