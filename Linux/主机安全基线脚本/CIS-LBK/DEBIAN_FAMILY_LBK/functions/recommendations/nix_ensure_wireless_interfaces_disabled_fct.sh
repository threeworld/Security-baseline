#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_wireless_interfaces_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure wireless interfaces are disabled"
#
ensure_wireless_interfaces_disabled_fct()
{

	echo
	echo "**** $RN $RNA"
	[ -n "$(command -v nmcli 2>/dev/null)" ] && nmcli radio all off

	return "${XCCDF_RESULT_PASS:-201}"
}