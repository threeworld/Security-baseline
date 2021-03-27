#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_cron_daemon_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure cron daemon is enabled"
#
ensure_cron_daemon_enabled_fct()
{

	echo
	echo "**** $RN $RNA"
	systemctl is-enabled crond | grep -q "enabled" || systemctl --now enable crond

	return "${XCCDF_RESULT_PASS:-201}"

}