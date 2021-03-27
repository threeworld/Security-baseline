#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_local_login_warning_banner_configured_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure local login warning banner is configured properly"
#
nix_ensure_local_login_warning_banner_configured_fct()
{
	# Ensure local login warning banner is configured properly
	echo
	echo \*\*\*\* Ensure\ local\ login\ warning\ banner\ is\ configured\ properly
	echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue

	return "${XCCDF_RESULT_PASS:-201}" 
}