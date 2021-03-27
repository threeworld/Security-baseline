#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_firewall_package_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    Recommendation "Ensure a Firewall package is installed"
#

deb_ensure_firewall_package_installed()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	# Set package manager information
	if [ -z "$PM" ] || [ -z "$PQ" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Test if a Firewall package is installed
	if $PQ ufw >/dev/null || $PQ nftables >/dev/null || $PQ iptables >/dev/null; then
		test=passed
	else
		# Install UncomplicatedFirewall
		! $PQ ufw >/dev/null && $PM -y install ufw
		if $PQ ufw >/dev/null || $PQ nftables >/dev/null || $PQ iptables >/dev/null; then
			test=remediated
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
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}