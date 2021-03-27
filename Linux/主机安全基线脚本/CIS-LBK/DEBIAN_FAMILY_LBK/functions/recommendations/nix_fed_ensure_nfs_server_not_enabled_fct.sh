#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_nfs_server_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure NFS is not enabled"
#
fed_ensure_nfs_server_not_enabled_fct()
{
	# Ensure NFS is not enabled
	echo
	echo "**** Ensure NFS is not enabled"
	systemctl is-enabled nfs-server 2>>/dev/null | grep -q "enabled" && systemctl --now disable nfs-server

	return "${XCCDF_RESULT_PASS:-201}"
}