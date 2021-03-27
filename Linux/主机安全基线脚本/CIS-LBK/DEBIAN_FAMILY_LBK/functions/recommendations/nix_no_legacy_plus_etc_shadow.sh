#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_no_legacy_plus_etc_shadow.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      09/25/20    Recommendation "Ensure no legacy "+" entries exist in /etc/shadow"

no_legacy_plus_etc_shadow_fct()
{

	echo
	echo "**** $RN $RNA"
	sed -ri '/^\+:.*$/ d' /etc/shadow

	return "${XCCDF_RESULT_PASS:-201}"
}