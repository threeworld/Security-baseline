#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_perms_etc_shadow_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      09/23/20     Recommendation "Ensure permissions on /etc/shadow are configured"
#
ensure_perms_etc_shadow_fct()
{

	echo
	echo "**** $RN $RNA"
	chmod -t,u-x-s,g-w-x-s,o-r-w-x /etc/shadow

	return "${XCCDF_RESULT_PASS:-201}"
}