#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_rsyslog_service_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure rsyslog Service is enabled"
#
ensure_rsyslog_service_enabled_fct()
{

	echo
	echo "**** $RN $RNA"
	if [ -z "$PQ" ] || [ -z "$PM" ]; then
		nix_package_manager_set
	fi
	$PQ rsyslog && ! systemctl is-enabled rsyslog | grep -q "enabled" && systemctl --now enable rsyslog

	return "${XCCDF_RESULT_PASS:-201}"
}