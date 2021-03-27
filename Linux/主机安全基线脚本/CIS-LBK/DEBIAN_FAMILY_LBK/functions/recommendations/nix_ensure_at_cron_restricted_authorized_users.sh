#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_at_cron_restricted_authorized_users.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/22/20    Recommendation "Ensure at/cron is restricted to authorized users"
#
ensure_at_cron_restricted_authorized_users()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	if [ ! -e /etc/cron.deny ] || [ ! -e /etc/at.deny ]; then
		test1=passed
	else
		[ -e /etc/cron.deny ] && rm -f /etc/cron.deny
		[ -e /etc/at.deny ] && rm -f /etc/at.deny
		[ ! -e /etc/crom.deny ] && [ ! -e /etc/at.deny ] && test1=remediated
	fi
	if [ -e /etc/cron.allow ] && [ -e /etc/at.allow ]; then
		test2=passed
	else
		[ ! -e /etc/cron.allow ] && touch /etc/cron.allow
		[ ! -e /etc/at.allow ] && touch /etc/at.allow
		[ -e /etc/cron.allow ] && [ -e /etc/at.allow ] && test2=remediated
	fi
	if [ "$(stat -Lc "%U %G" /etc/cron.allow)" = "root root" ] && [ "$(stat -Lc "%U %G" /etc/at.allow)" = "root root" ]; then
		test3=passed
	else
		[ "$(stat -Lc "%U %G" /etc/cron.allow)" != "root root" ] && chown root:root /etc/cron.allow
		[ "$(stat -Lc "%U %G" /etc/at.allow)" != "root root" ] && chown root:root /etc/at.allow
		[ "$(stat -Lc "%U %G" /etc/cron.allow)" = "root root" ] && [ "$(stat -Lc "%U %G" /etc/at.allow)" = "root root" ] && test3=remediated
	fi
	if stat -Lc "%A" /etc/cron.allow | grep -Eq '^-[r-][w-]-------$' && stat -Lc "%A" /etc/at.allow | grep -Eq '^-[r-][w-]-------$'; then
		test4=passed
	else
		! stat -Lc "%A" /etc/cron.allow | grep -Eq '^-[r-][w-]-------$' && chmod u-x,go-wrx /etc/cron.allow
		! stat -Lc "%A" /etc/at.allow | grep -Eq '^-[r-][w-]-------$' && chmod u-x,go-wrx /etc/at.allow
		stat -Lc "%A" /etc/cron.allow | grep -Eq '^-[r-][w-]-------$' && stat -Lc "%A" /etc/at.allow | grep -Eq '^-[r-][w-]-------$' && test4=remediated
	fi

	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi

#	[ -e /etc/cron.deny ] && rm -f /etc/cron.deny
#	[ -e /etc/at.deny ] && rm -f /etc/at.deny
#	[ ! -f /etc/cron.deny ] && touch /etc/cron.deny
#	[ ! -f /etc/at.deny ] && touch /etc/at.deny
#	chmod og-rwx /etc/cron.allow /etc/at.allow
#	chown root:root /etc/cron.allow /etc/at.allow

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