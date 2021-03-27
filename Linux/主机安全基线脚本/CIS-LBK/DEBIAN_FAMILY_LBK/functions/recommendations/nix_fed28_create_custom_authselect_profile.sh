#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_create_custom_authselect_profile.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/24/20    Recommendation "Create custom authselect profile"
# 
fed28_create_custom_authselect_profile()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if [ -n "$(authselect list | awk -F / '/custom\// { print $2 }' | cut -f1)" ]; then
		test=passed
	else
		authselect create-profile custom-profile -b sssd --symlink-meta
		authselect select custom-profile
		authselect current | grep -iq 'Profile ID: custom/' && test=remediated
	fi
	# Set return code and return
	if [ "$test" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	elif [ "$test" = remediated ]; then
		echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-103}"
	else
		echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}