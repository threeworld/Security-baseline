#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_remote_login_warning_banner_configured_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure remote login warning banner is configured properly"
#
nix_ensure_remote_login_warning_banner_configured_fct()
{
	# Ensure remote login warning banner is configured properly
	echo
	echo \*\*\*\* Ensure\ remote\ login\ warning\ banner\ is\ configured\ properly
	echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net

	return "${XCCDF_RESULT_PASS:-201}" 
}