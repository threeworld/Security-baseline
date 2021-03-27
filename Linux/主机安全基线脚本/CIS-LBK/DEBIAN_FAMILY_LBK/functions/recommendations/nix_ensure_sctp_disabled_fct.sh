#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_ensure_sctp_disabled_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure SCTP is disabled"
#
ensure_sctp_disabled_fct()
{

	echo
	echo \*\*\*\* Ensure\ SCTP\ is\ disabled
	modprobe -n -v sctp | grep "^install /bin/true$" || echo "install sctp /bin/true" >> /etc/modprobe.d/sctp.conf
	lsmod | grep -E "^sctp\s" && rmmod sctp

	return "${XCCDF_RESULT_PASS:-201}"
}