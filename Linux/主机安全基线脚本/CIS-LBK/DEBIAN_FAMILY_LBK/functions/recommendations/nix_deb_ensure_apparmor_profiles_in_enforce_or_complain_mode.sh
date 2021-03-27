#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_apparmor_profiles_in_enforce_or_complain_mode.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure all AppArmor Profiles are in enforce or complain mode"
# 
deb_ensure_apparmor_profiles_in_enforce_or_complain_mode()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	TPL=$(apparmor_status | awk '/profiles are loaded./ {print $1}')
	TPEM=$(apparmor_status | awk '/profiles are in enforce mode./ {print $1}')
	TPCM=$(apparmor_status | awk '/profiles are in complain mode./ {print $1}')
	TPC=$((TPEM+TPCM))
	if [ "$TPC" = "$TPL" ]; then
		test=passed
	else
		aa-enforce /etc/apparmor.d/*
		TPL=$(apparmor_status | awk '/profiles are loaded./ {print $1}')
		TPEM=$(apparmor_status | awk '/profiles are in enforce mode./ {print $1}')
		TPCM=$(apparmor_status | awk '/profiles are in complain mode./ {print $1}')
		TPC=$((TPEM+TPCM))
		[ "$TPC" = "$TPL" ] && test=remediated
	fi

	[ "$(apparmor_status | awk '/processes are unconfined but have a profile defined./ {print $1}')" != 0 ] && test=manual

	# Set return code and return
	case "$test" in
		passed)
			echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-101}"
			;;
		remediated)
			echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-103}"
			;;
		manual)
			echo "Recommendation \"$RNA\" requires manual remediation" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-106}"
			;;
		NA)
			echo "Recommendation \"$RNA\" Another firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}