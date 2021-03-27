#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_default_deny_firewall_policy.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/07/20    Recommendation "Ensure default deny firewall policy"
# 
fed_ensure_default_deny_firewall_policy()
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
			# Test for hook input (test1)
			if nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+input\s+[^#]+;\s*policy\s+drop\b'; then
				test1=passed
			else
				if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+input\s+[^#]+;\s*policy\s+drop\b' && test1=remediated
				else
					nft create table inet filter
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+input\s+[^#]+;\s*policy\s+drop\b' && test1=remediated
				fi
			fi

			# Test for hook forward (test2)
			if nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+forward\s+[^#]+;\s*policy\s+drop\b'; then
				test2=passed
			else
				if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+forward\s+[^#]+;\s*policy\s+drop\b' && test2=remediated
				else
					nft create table inet filter
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+forward\s+[^#]+;\s*policy\s+drop\b' && test2=remediated
				fi
			fi

			# Test for hook output (test3)
			if nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+output\s+[^#]+;\s*policy\s+drop\b'; then
				test3=passed
			else
				if nft list tables | grep -Eq '^table\sinet\sfilter\b';then
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+output\s+[^#]+;\s*policy\s+drop\b' && test3=remediated
				else
					nft create table inet filter
					nft chain inet filter input { policy drop \; }
					nft list ruleset | grep -Eqs 'type\s+filter\s+hook\s+output\s+[^#]+;\s*policy\s+drop\b' && test3=remediated
				fi
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