#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_ensure_X_Window_System_not_installed_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure X Window System is not installed"
#
fed_ensure_X_Window_System_not_installed_fct()
{
	# Ensure X Window System is not installed
	[ -z "$PR" ] && nix_package_manager_set
	echo
	echo \*\*\*\* Ensure\ X\ Window\ System\ is\ not\ installed
	$PR -y xorg-x11*
	$PR -y xserver-xorg.*

	return "${XCCDF_RESULT_PASS:-201}" 
}