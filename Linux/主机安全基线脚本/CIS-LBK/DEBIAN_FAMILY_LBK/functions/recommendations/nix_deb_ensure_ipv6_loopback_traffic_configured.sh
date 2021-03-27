#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_ipv6_loopback_traffic_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/20/20    Recommendation "Ensure IPv6 loopback traffic is configured"
# 
deb_ensure_ipv6_loopback_traffic_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && deb_firewall_chk
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$FWIN" != "IPt" ] || [ "$no_ipv6" = "yes" ]; then
		test=NA
	else
		# Check is package manager is defined
		if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
			nix_package_manager_set
		fi
		if ! $PQ iptables >/dev/null; then
			test=manual
		else
			# Test for ip6tables -A INPUT -i lo -j ACCEPT (test1)
			if ip6tables -L INPUT -v -n | grep -Eqs '^\s*\S+\s+\S+\s+ACCEPT\s+all\s+lo\b'; then
				test1=passed
			else
				ip6tables -A INPUT -i lo -j ACCEPT
				ip6tables -L INPUT -v -n | grep -Eqs '^\s*\S+\s+\S+\s+ACCEPT\s+all\s+lo\b' && test1=remediated
			fi

			# ip6tables -A OUTPUT -o lo -j ACCEPT (test2)
			if ip6tables -L OUTPUT -v -n | grep -Eqs '^\s*\S+\s+\S+\s+ACCEPT\s+all\s+\*\s+lo\b'; then
				test2=passed
			else
				ip6tables -A OUTPUT -o lo -j ACCEPT
				ip6tables -L OUTPUT -v -n | grep -Eqs '^\s*\S+\s+\S+\s+ACCEPT\s+all\s+\*\s+lo\b' && test2=remediated
			fi

			# Test for ip6tables -A INPUT -s ::1 -j DROP (test3)
			if ip6tables -L INPUT -v -n | grep -Es '^\s*\S+\s+\S+\s+DROP\s+all\s+\*\s+\*\s+\:\:1\b'; then
				test3=passed
			else
				ip6tables -A INPUT -s ::1 -j DROP
				ip6tables -L INPUT -v -n | grep -Es '^\s*\S+\s+\S+\s+DROP\s+all\s+\*\s+\*\s+\:\:1\b' && test3=remediated
			fi

			# Test for output status
			if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
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