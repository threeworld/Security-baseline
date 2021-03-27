#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_dccp_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure DCCP is disabled"
#
ensure_dccp_disabled_fct()
{

	echo
	echo \*\*\*\* Ensure\ DCCP\ is\ disabled
	modprobe -n -v dccp | grep "^install /bin/true$" || echo "install dccp /bin/true" >> /etc/modprobe.d/dccp.conf
	lsmod | grep -E "^dccp\s" && rmmod dccp

	return "${XCCDF_RESULT_PASS:-201}"
}