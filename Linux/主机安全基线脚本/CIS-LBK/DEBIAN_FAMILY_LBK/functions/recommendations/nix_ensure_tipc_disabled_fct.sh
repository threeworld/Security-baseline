#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_tipc_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure TIPC is disabled"
#
ensure_tipc_disabled_fct()
{

	echo
	echo "**** $RN $RNA"
	modprobe -n -v tipc | grep "^install /bin/true$" || echo "install tipc /bin/true" >> /etc/modprobe.d/tipc.conf
	lsmod | grep -E "^tipc\s" && rmmod tipc

	return "${XCCDF_RESULT_PASS:-201}"
}