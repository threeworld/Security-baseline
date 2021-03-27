#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_ftp_server_not_enabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure FTP Server is not enabled"
#
fed_ensure_ftp_server_not_enabled_fct()
{
	# Ensure FTP Server is not enabled
	echo
	echo "**** Ensure FTP Server is not enabled"
	systemctl is-enabled vsftpd 2>>/dev/null | grep -q "enabled" && systemctl --now disable vsftpd

	return "${XCCDF_RESULT_PASS:-201}"
}