#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_nonempty_pw_fields.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Patrick Araya      09/25/20    Recommendation "Ensure password fields are not empty"
#
nonempty_pw_fields_fct()
{

	echo
	echo "**** $RN $RNA"
	awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow | passwd -l

	return "${XCCDF_RESULT_PASS:-201}"
}