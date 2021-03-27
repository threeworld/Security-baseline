#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_cron_restricted_authorized_users.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/04/20    Recommendation "Ensure cron is restricted to authorized users"
#
ensure_cron_restricted_authorized_users()
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
		if [ -z /etc/cron.deny ]; then
			test1=passed
		else
			rm -f /etc/cron.deny
			[ -z /etc/cron.deny ] && test1=remediated
		fi
		if [ -e /etc/cron.allow ]; then
			test2=passed
		else
			touch /etc/cron.allow
			chmod u-x,og-rwx /etc/cron.allow
			chown root:root /etc/cron.allow
			[ -e /etc/cron.allow ] && test2=remediated
		fi
		if [ -f /etc/cron.allow ] && [ "$(stat -Lc "%A" /etc/cron.allow | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/cron.allow)" = "root root" ]; then
			test3=passed
		else
			[ -f /etc/cron.allow ] && chmod u-x,og-rwx /etc/cron.allow && chown root:root /etc/cron.allow
			[ -f /etc/cron.allow ] && [ "$(stat -Lc "%A" /etc/cron.allow | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/cron.allow)" = "root root" ] && test3=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
				test=passed
			else
				test=remediated
			fi
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