#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ufw_ensure_loopback_traffic_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/19/20    Recommendation "Ensure loopback traffic is configured"
# 
deb_ensure_ufw_loopback_traffic_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if UncomplicatedFirewall (ufw) is the firewall being used
	if [ -z "$FWIN" ]; then
		deb_firewall_chk
	fi
	if [ "$FWIN" != "UFw" ]; then
		test=NA
	else
		test1="" test2="" test3=""
		if ufw status verbose | grep -Eq "^Anywhere\s+on\s+lo\s+ALLOW\s+IN\s+Anywhere\b"; then
			test1=passed
		else
			ufw allow in on lo
			ufw status verbose | grep -Eq "^Anywhere\s+on\s+lo\s+ALLOW\s+IN\s+Anywhere\b" && test1=remediated
		fi
		if ufw status verbose | grep -Eq "^Anywhere\s+DENY\s+IN\s+127\.0\.0\.0\/8\b"; then
			test2=passed
		else
			ufw deny in from 127.0.0.0/8
			ufw status verbose | grep -Eq "^Anywhere\s+DENY\s+IN\s+127\.0\.0\.0\/8\b" && test2=remediated
		fi
		[ -z "$no_ipv6" ] && ipv6_chk
		if [ "$no_ipv6" = "yes" ] || ufw status verbose | grep -Eq "^Anywhere\s+\(v6\)\s+DENY\s+IN\s+\:\:1\b"; then
			test3=passed
		else
			ufw deny in from ::1
			ufw status verbose | grep -Eq "^Anywhere\s+\(v6\)\s+DENY\s+IN\s+\:\:1\b" && test3=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
				test=passed
			else
				test=remediated
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
			echo "Recommendation \"$RNA\" Another firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}