#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendation/nix_ensure_XD_NX_support_enabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/29/20    Recommendation "Ensure XD/NX support is enabled"
#
ensure_XD_NX_support_enabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if arch | grep -q "x86_64"; then
		test=NA
	else
		if [ -n "$(command -v journalctl)" ] ; then
			journalctl | grep -q 'protection: active' && test="passed"
		elif [ -s "/var/log/dmesg" ] && [ -s "/proc/info" ] && [ -s "/var/log/dmesg" ] ; then
			if [ -n "$(grep 'noexec[0-9]*=off' /proc/cmdline)" ] || [ -z "$(grep -E -i ' (pae|nx) ' /proc/cpuinfo)" ] || [ -n "$(grep '\sNX\s.*\sprotection:\s' /var/log/dmesg | grep -v active)" ]; then
				test="manual"
			else
				test="passed"
			fi
		else
			test="manual"
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
			echo "Recommendation \"$RNA\" System is 64 bit - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}