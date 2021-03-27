#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_nis_server_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure NIS Server is not enabled"
#
fed_ensure_nis_server_not_enabled_fct()
{

	echo
	echo "**** Ensure NIS Server is not enabled"
	systemctl is-enabled ypserv 2>>/dev/null | grep -q "enabled" && systemctl --now disable ypserv

	return "${XCCDF_RESULT_PASS:-201}"
}