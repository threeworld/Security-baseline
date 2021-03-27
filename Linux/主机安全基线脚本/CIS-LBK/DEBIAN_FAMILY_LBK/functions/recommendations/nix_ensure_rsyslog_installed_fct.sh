#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_rsyslog_installed_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure rsyslog is installed"
#
ensure_rsyslog_installed_fct()
{

	echo
	echo "**** $RN $RNA"
	if [ -z "$PQ" ] || [ -z "$PM" ]; then
		nix_package_manager_set
	fi
	! $PQ 2>>/dev/null rsyslog && $PM install -y rsyslog

	return "${XCCDF_RESULT_PASS:-201}"
}