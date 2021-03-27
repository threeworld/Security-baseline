#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_firewall_package_installed.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    Recommendation "Ensure a Firewall package is installed"
#

fed28_ensure_firewall_package_installed()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	# Set package manager information
	if [ -z "$PM" ] || [ -z "$PQ" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Test if a Firewall package is installed
	if $PQ firewalld || $PQ nftables || $PQ iptables; then
		test=passed
	else
		# Install Firewalld
#		$PM -y install firewalld
		! $PQ firewalld && $PM -y install firewalld
		if ! grep -Eqs '^\s*AllowZoneDrifting=no' /etc/firewalld/firewalld.conf; then
			grep 'AllowZoneDrifting=' /etc/firewalld/firewalld.conf && sed -ri 's/^\s*(#\s*)?([Aa]llow[Zz]one[Dd]rifting\s*=\s*\S+\b)(.*)?$/AllowZoneDrifting=no \3/' /etc/firewalld/firewalld.conf || echo "AllowZoneDrifting=no" >> /etc/firewalld/firewalld.conf
		fi
#		! systemctl is-enabled firewalld && systemctl unmask firewalld && systemctl --now enable firewalld
#		! systemctl status firewalld | grep -q 'Active: active (running)' && systemctl start firewalld
#		if systemctl list-unit-files | grep enabled | grep -q ssh; then
#			firewall-cmd --permanent --zone=public --add-service=ssh
#			firewall-cmd --reload
#		fi
		if $PQ firewalld || $PQ nftables || $PQ iptables; then
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