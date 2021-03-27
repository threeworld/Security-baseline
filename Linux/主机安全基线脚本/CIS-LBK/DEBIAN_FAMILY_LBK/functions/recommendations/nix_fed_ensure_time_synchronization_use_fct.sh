#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_time_synchronization_use_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure time synchronization is in use"
#
fed_ensure_time_synchronization_use_fct()
{
# Ensure time synchronization is in use
echo
echo \*\*\*\* Ensure\ time\ synchronization\ is\ in\ use
rpm -q ntp || rpm -q chrony || yum -y install ntp

	return "${XCCDF_RESULT_PASS:-201}" 
}