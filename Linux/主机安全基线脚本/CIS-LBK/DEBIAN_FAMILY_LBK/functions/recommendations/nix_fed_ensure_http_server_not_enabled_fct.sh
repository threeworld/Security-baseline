#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_http_server_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure HTTP server is not enabled"
#
fed_ensure_http_server_not_enabled_fct()
{
	# Ensure HTTP server is not enabled
	echo
	echo \*\*\*\* Ensure\ HTTP\ server\ is\ not\ enabled
	systemctl is-enabled httpd 2>>/dev/null | grep -q "enabled" && systemctl --now disable httpd

	return "${XCCDF_RESULT_PASS:-201}"
}