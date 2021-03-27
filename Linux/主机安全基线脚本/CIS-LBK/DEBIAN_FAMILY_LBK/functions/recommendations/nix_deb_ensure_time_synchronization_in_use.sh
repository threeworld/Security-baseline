#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_deb_ensure_time_synchronization_in_use.sh
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure time synchronization is in use"
#
deb_ensure_time_synchronization_in_use()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if [ -z "$PQ" ] || [ -z "$PM" ]; then
		nix_package_manager_set
	fi
	if $PQ ntp >/dev/null || $PQ chrony >/dev/null || systemctl is-enabled systemd-timesyncd | grep -q 'enabled'; then
		test=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Time synchronization is in use, enabling systemd-timesyncd" | tee -a "$LOG" 2>> "$ELOG"
		if systemctl is-enabled systemd-timesyncd | grep -Eq '(enabled|disabled|masked)'; then
			systemctl --now unmask systemd-timesyncd
			systemctl is-enabled systemd-timesyncd | grep -q 'enabled' && test=remediated
		fi
	fi

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
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}