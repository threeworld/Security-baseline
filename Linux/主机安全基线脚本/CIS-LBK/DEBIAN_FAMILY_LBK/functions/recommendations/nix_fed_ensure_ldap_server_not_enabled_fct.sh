#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_ldap_server_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure LDAP server is not enabled"
#
fed_ensure_ldap_server_not_enabled_fct()
{
	# Ensure LDAP server is not enabled
	echo
	echo "**** Ensure LDAP server is not enabled"
	systemctl is-enabled slapd 2>>/dev/null | grep -q "enabled" && systemctl --now disable slapd

	return "${XCCDF_RESULT_PASS:-201}"
}