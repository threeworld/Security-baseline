#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ip_forwarding_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure IP forwarding is disabled"
#
ip_forwarding_disabled_fct()
{

echo
echo \*\*\*\* Ensure\ IP\ forwarding\ is\ disabled
egrep -q "^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 0\2/" /etc/sysctl.conf || echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf

	return "${XCCDF_RESULT_PASS:-201}"
}