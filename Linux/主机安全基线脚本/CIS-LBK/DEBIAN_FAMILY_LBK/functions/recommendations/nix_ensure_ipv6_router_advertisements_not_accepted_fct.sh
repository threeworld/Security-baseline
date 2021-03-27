#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_ipv6_router_advertisements_not_accepted_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure IPv6 router advertisements are not accepted"
#
ensure_ipv6_router_advertisements_not_accepted_fct()
{

	echo
	echo \*\*\*\* Ensure\ IPv6\ router\ advertisements\ are\ not\ accepted
	grep -Eq "^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
	grep -Eq "^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf

	return "${XCCDF_RESULT_PASS:-201}"
}