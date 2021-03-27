#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_nftables_rules_permanent.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/07/20    Recommendation "Ensure nftables rules are permanent"
# 
fed_ensure_nftables_rules_permanent()
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
			if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook input/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
				test1=passed
			fi

			# Test for hook forward (test2)
			if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook forward/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
				test2=passed
			fi

			# Test for hook output (test3)
			if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook output/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
				test3=passed
			fi
			# Test is remediation is required
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
				test=passed
			else
				if [ -s /etc/nftables/cis_nftables.rules ]; then
					echo "include \"/etc/nftables/cis_nftables.rules\"" /etc/sysconfig/nftables.conf
				else
					nft list ruleset > /etc/nftables/cis_nftables.rules
					echo "include \"/etc/nftables/cis_nftables.rules\"" /etc/sysconfig/nftables.conf
				fi
				# Test if remediation was successful
				if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook input/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
					test1=remediated
				fi

				# Test for hook forward (test2)
				if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook forward/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
					test2=remediated
				fi

				# Test for hook output (test3)
				if grep -Eqs "^\s*include" /etc/sysconfig/nftables.conf && awk '/hook output/,/}/' "$(awk '$1 ~ /^\s*include/ { gsub("\"","",$2);print $2 }' /etc/sysconfig/nftables.conf)"; then
					test3=remediated
				fi
				# Set output to remediated if remediation was successfuk
				[ "$test1" = remediated ] && [ "$test2" = remediated ] && [ "$test3" = remediated ] && test=remediated
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