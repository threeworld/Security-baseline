#!/usr/bin/env sh
#
# CIS-LBK General Function
# ~/CIS-LBK/functions/general/nix_ipv6_chk.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    General "Check if IPv6 is disabled"
# 
ipv6_chk()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting Determine if IPv6 is disabled -" | tee -a "$LOG" 2>> "$ELOG"
	t1="" t2=""
	no_ipv6="no"
	# Check running grub configuration
	if [ -s /boot/grub2/grub.cfg ]; then
		if grep -qs "^\s*linux" /boot/grub2/grub.cfg && ! grep -s "^\s*linux" /boot/grub2/grub.cfg | grep -vq ipv6.disabled=1; then
			echo "IPv6 is disabled in /boot/grub2/grub.cfg" | tee -a "$LOG" 2>> "$ELOG"
			no_ipv6="yes"
		fi
	fi
	if [ -s /boot/grub/grub.cfg ]; then
		if grep -qs "^\s*linux" /boot/grub/grub.cfg && ! grep -s "^\s*linux" /boot/grub/grub.cfg | grep -vq ipv6.disabled=1; then
			echo "IPv6 is disabled in /boot/grub/grub.cfg" | tee -a "$LOG" 2>> "$ELOG"
			no_ipv6="yes"
		fi
	fi
	if [ -s /boot/grub2/grubenv ]; then
		if grep -qs 'kernelopts=' /boot/grub2/grubenv && ! grep -s 'kernelopts=' /boot/grub2/grubenv | grep -vq ipv6.disable=1; then
			echo "IPv6 is disabled in /boot/grub2/grubenv" | tee -a "$LOG" 2>> "$ELOG"
			no_ipv6="yes"
		fi
	fi
	# check Running sysctl config
	if sysctl net.ipv6.conf.all.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && sysctl net.ipv6.conf.default.disable_ipv6 | grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$"; then
		t1=passed
	fi
	if grep -Eqs "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf && grep -Eqs "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf; then
		t2=passed
	fi
	if [ "$t1" = passed ] && [ "$t2" = passed ]; then
		echo "IPv6 is disabled in sysctl" | tee -a "$LOG" 2>> "$ELOG"
		no_ipv6="yes"
	fi
	if [ "$no_ipv6" = no ] ; then
		echo "IPv6 is enabled on the system" | tee -a "$LOG" 2>> "$ELOG"
	fi
	# Export no_ipv6
	export no_ipv6
}