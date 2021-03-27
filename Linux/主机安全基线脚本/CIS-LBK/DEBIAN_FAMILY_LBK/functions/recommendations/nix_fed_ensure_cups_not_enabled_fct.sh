#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_cups_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure CUPS is not enabled"
#
fed_ensure_cups_not_enabled_fct()
{

	echo
	echo "**** Ensure CUPS is not enabled"
	systemctl is-enabled cups 2>>/dev/null | grep -q "enabled" && systemctl --now disable cups

	return "${XCCDF_RESULT_PASS:-201}"
}