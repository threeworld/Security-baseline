#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_telnet_client_not_installed_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure telnet client is not installed"
#
fed_ensure_telnet_client_not_installed_fct()
{

	echo
	echo "**** Ensure telnet client is not installed"
	if [ -z "$PQ" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	$PQ 2>>/dev/null telnet && $PR -y telnet

	return "${XCCDF_RESULT_PASS:-201}"
}