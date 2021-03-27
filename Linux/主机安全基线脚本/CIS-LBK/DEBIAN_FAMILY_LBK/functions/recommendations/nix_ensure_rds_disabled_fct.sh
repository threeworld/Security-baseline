#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_rds_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure RDS is disabled"
#
ensure_rds_disabled_fct()
{

	echo
	echo \*\*\*\* Ensure\ RDS\ is\ disabled
	modprobe -n -v rds | grep "^install /bin/true$" || echo "install rds /bin/true" >> /etc/modprobe.d/rds.conf
	lsmod | grep -E "^rds\s" && rmmod rds

	return "${XCCDF_RESULT_PASS:-201}"
}