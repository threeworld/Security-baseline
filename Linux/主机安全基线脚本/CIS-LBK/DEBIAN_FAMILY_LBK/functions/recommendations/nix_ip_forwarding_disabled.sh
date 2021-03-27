#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ip_forwarding_disabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/20/20    Recommendation "Ensure IP forwarding is disabled"
#
ip_forwarding_disabled()
{

	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3="" test4=""
	# Check running net.ipv4.ip_forward
	echo "- $(date +%d-%b-%Y' '%T) - Checking net.ipv4.ip_forward in the running config" | tee -a "$LOG" 2>> "$ELOG"
	if sysctl net.ipv4.ip_forward | grep -Eq '^net.ipv4.ip_forward\s*=\s+0\b'; then
		test1=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating net.ipv4.ip_forward in the running config" | tee -a "$LOG" 2>> "$ELOG"
		sysctl -w net.ipv4.ip_forward=0
		sysctl -w net.ipv4.route.flush=1
		sysctl net.ipv4.ip_forward | grep -Eq '^net.ipv4.ip_forward\s*=\s+0\b' && test1=remediated
	fi
	# check running net.ipv6.conf.all.forwarding
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$no_ipv6" = yes ]; then
		echo "- $(date +%d-%b-%Y' '%T) - ipv6 is disabled, skipping check for net.ipv6.conf.all.forwarding in the running config" | tee -a "$LOG" 2>> "$ELOG"
		test2=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Checking net.ipv6.conf.all.forwarding in the running config" | tee -a "$LOG" 2>> "$ELOG"
		if sysctl net.ipv6.conf.all.forwarding | grep -Eq '^net.ipv6.conf.all.forwarding\s*=\s*0\b'; then
			test2=passed
		else
			sysctl -w net.ipv6.conf.all.forwarding=0
			sysctl -w net.ipv6.route.flush=1
			sysctl net.ipv6.conf.all.forwarding | grep -Eq '^net.ipv6.conf.all.forwarding\s*=\s*0\b' && test2=remediated
		fi
	fi
	# Check files for net.ipv4.ip_forward = 1
	echo "- $(date +%d-%b-%Y' '%T) - Checking net.ipv4.ip_forward in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
	if ! grep -Elqs "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
		test3=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Remediating net.ipv4.ip_forward in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
		grep -Els "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read -r filename; do
			sed -ri "s/^\s*(net\.ipv4\.ip_forward\s*=\s*\S+\b).*$/# *REMOVED by CIS-LBK* \1/" "$filename"
		done
		! grep -Elqs "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && test3=remediated
	fi
	# Check files for net.ipv6.conf.all.forwarding = 1
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$no_ipv6" = yes ]; then
		echo "- $(date +%d-%b-%Y' '%T) - ipv6 is disabled, skipping check for net.ipv6.conf.all.forwarding in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
		test4=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Checking net.ipv6.conf.all.forwarding in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
		if ! grep -Elqs "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
			test4=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - Remediating net.ipv6.conf.all.forwarding in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
			grep -Els "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read -r filename; do
				sed -ri "s/^\s*(net\.ipv6\.conf\.all\.forwarding\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" "$filename"
			done
			! grep -Elqs "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && test4=remediated
		fi
	fi
	# Check status of tests
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ]; then
			test=passed
		else
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