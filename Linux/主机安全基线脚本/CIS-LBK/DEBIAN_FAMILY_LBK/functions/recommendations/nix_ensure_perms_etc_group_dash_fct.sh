#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_perms_etc_group_dash_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      09/23/20     Recommendation "Ensure permissions on /etc/group- are configured"
#
ensure_perms_etc_group_dash_fct()
{

	echo
	echo "**** $RN $RNA"
	chmod -t,u-x-s,g-r-w-x-s,o-r-w-x /etc/group-

	return "${XCCDF_RESULT_PASS:-201}"
}