#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_rpc_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure RPC is not enabled"
#
fed_ensure_rpc_not_enabled_fct()
{
	# Ensure RPC is not enabled
	echo
	echo "**** Ensure RPC is not enabled"
	systemctl is-enabled rpcbind 2>>/dev/null | grep -q "enabled" && systemctl --now disable rpcbind

	return "${XCCDF_RESULT_PASS:-201}"
}