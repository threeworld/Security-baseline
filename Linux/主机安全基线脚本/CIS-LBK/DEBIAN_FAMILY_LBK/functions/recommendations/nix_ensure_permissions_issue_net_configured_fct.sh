#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_permissions_issue_net_configured_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure permissions on /etc/issue.net are configured"
#
nix_ensure_permissions_issue_net_configured_fct()
{
	# Ensure permissions on /etc/issue.net are configured
	echo
	echo \*\*\*\* Ensure\ permissions\ on\ /etc/issue.net\ are\ configured
	chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/issue.net

	return "${XCCDF_RESULT_PASS:-201}" 
}