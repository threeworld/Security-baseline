#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_permissions_logfiles_configured_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure permissions on all logfiles are configured"
#
ensure_permissions_logfiles_configured_fct()
{

	echo
	echo "**** $RN $RNA"
	find /var/log -type f -exec chmod g-wx,o-rwx "{}" + -o -type d -exec chmod g-w,o-rwx "{}" +

	return "${XCCDF_RESULT_PASS:-201}"
}