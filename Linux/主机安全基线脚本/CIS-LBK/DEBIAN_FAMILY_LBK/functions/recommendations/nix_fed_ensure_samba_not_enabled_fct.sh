#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_samba_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure Samba is not enabled"
#
fed_ensure_samba_not_enabled_fct()
{
	# Ensure Samba is not enabled
	echo
	echo \*\*\*\* Ensure\ Samba\ is\ not\ enabled
	systemctl is-enabled smb 2>>/dev/null | grep -q "enabled" && systemctl --now disable smb

	return "${XCCDF_RESULT_PASS:-201}"
}