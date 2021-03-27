#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_deb_ensure_systemd-timesyncd_configured.sh
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure systemd-timesyncd is configured"
#
deb_ensure_systemd-timesyncd_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if [ -z "$PQ" ] || [ -z "$PM" ]; then
		nix_package_manager_set
	fi
	if $PQ ntp >/dev/null || $PQ chrony >/dev/null; then
		test=NA
	else
		if systemctl is-enabled systemd-timesyncd | grep -q 'enabled' && timedatectl status | grep -q 'NTP enabled: yes' && timedatectl status | grep -q 'NTP synchronized: yes'; then
			test=passed
		else
			test=manual
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
		NA)
			echo "Recommendation \"$RNA\" Chrony or ntp installed on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}