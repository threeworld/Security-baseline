#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_disable_ipv6.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Disable IPv6"
# 
disable_ipv6()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if IPv6 is disabled in grub.cfg
	[ -e /boot/grub2/grub.cfg ] && [ -z "$(grep "^\s*linux" /boot/grub2/grub.cfg | grep -v ipv6.disable=1)" ] && test=passed
	[ -e /boot/grub/grub.cfg ] && [ -z "$(grep "^\s*linux" /boot/grub2/grub.cfg | grep -v ipv6.disable=1)" ] && test=passed
	# Check if IPv6 is disabled in a sysctl conf file
	grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf && grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf && sysctl net.ipv6.conf.all.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && sysctl net.ipv6.conf.default.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && test=passed
	echo "- $(date +%d-%b-%Y' '%T) - Completed $RNA" | tee -a "$LOG" 2>> "$ELOG"
	# Set return code and return
	if [ "$test1" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	else
		echo "Recommendation \"$RNA\" Informational. IPv6 not disabled" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-106}"
	fi
}