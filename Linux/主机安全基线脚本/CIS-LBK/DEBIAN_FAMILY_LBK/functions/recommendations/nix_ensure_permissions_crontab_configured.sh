#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_permissions_crontab_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/04/20    Recommendation "Ensure permissions on /etc/crontab are configured"
#
ensure_permissions_crontab_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ cronie >/dev/null && ! $PQ cron >/dev/null; then
		test=NA
	else
		if [ -f /etc/crontab ] && [ "$(stat -Lc "%A" /etc/crontab | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/crontab)" = "root root" ]; then
			test=passed
		else
			[ -f /etc/crontab ] && chmod u-x,og-rwx /etc/crontab && chown root:root /etc/crontab
			[ -f /etc/crontab ] && [ "$(stat -Lc "%A" /etc/crontab | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/crontab)" = "root root" ] && test=remediated
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
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}