#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_wireless_interfaces_disabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/03/20    Recommendation "Ensure wireless interfaces are disabled"
#
ensure_wireless_interfaces_disabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if command -v mnci >/dev/null 2>&1 ; then
		nmcli radio all | grep -Eq "^\s*\S+\s+disabled\s+\S+\s+disabled\s*$" && test=passed
	else
		if [ -z "$(find /sys/class/net/ -type d -name 'wireless')" ]; then
			test=passed
		else
			drivers=$(for driverdir in $(find /sys/class/net/* -type d -name 'wireless' | xargs -0 dirname | xargs basename); do basename "$(readlink -f /sys/class/net/"$driverdir"/device/driver)";done | sort -u)
			for dm in $drivers; do
				if grep -Eq "^\s*install $dm \/bin\/(true|false)" /etc/modprobe.d/*.conf; then
					test=passed
				fi
			done
		fi
	fi
	[ "$test" != passed ] && test=manual
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
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}