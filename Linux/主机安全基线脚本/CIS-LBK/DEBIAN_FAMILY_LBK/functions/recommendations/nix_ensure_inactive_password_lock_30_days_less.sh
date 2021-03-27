#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_inactive_password_lock_30_days_less.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure inactive password lock is 30 days or less"
# 
ensure_inactive_password_lock_30_days_less()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	cde="$(date "+%s")"
	test=""
	test1=""
	test2=""
	# Sub function to check users' inactive_password_lock days
	ipl_chk()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Starting check users for account inactivity" | tee -a "$LOG" 2>> "$ELOG"
		awk -F : '/^[^:]+:[^!*]/ {print $7}' /etc/shadow | while read -r days; do
			[ -z "$days" ] && return "${XCCDF_RESULT_FAIL:-102}"
			if [ "$days" -gt "30" ] || [ "$days" = "-1" ]; then
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	# Sub function to remediate users' inactive_password_lock days
	ipl_remediate()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Starting remediate users for account inactivity" | tee -a "$LOG" 2>> "$ELOG"
		awk -F : '/^[^:]+:[^!*]/ {print $1 " " $7}' /etc/shadow | while read -r user days; do
			if [ -z "$days" ] || [ "$days" -gt "30" ] || [ "$days" = "-1" ]; then
				if [ "$user" = "root" ]; then
					if [ "$(date --date="$(chage --list "$user" | grep '^Password inactive' | cut -d: -f2)" +%s)" -le "$((cde-1987200))" ]; then
						echo "User \"$user\" account may be locked due to inactivity.  Please ensue $user has logged in in the past 30 days before remediating" | tee -a "$LOG" 2>> "$ELOG"
					else
						chage --inactive 30 "$user"
					fi
				else
					[ "$(date --date="$(chage --list "$user" | grep '^Password inactive' | cut -d: -f2)" +%s)" -le "$((cde-1987200))" ] && echo "User \"$user\" account may be locked due to inactivity." | tee -a "$LOG" 2>> "$ELOG"
					chage --inactive 30 "$user"
				fi
			fi
		done
	}
	echo "- $(date +%d-%b-%Y' '%T) - Starting check useradd defaults" | tee -a "$LOG" 2>> "$ELOG"
	if [ -n "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" ] && [ "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" -le "30" ] && [ "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" != "-1" ]; then
		test1=passed
	else
		echo "- $(date +%d-%b-%Y' '%T) - Starting remediate useradd defaults" | tee -a "$LOG" 2>> "$ELOG"
		useradd -D -f 30
		[ -n "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" ] && [ "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" -le "30" ] && [ "$(useradd -D | awk -F = '/INACTIVE/ {print $2}')" != "-1" ] && test1=remediated
	fi
	# Check users for account inactivity days
	ipl_chk
	if [ "$?" != "102" ]; then
		test2=passed
	else
		# Remediate users with PASS_MIN_DAYS greater than 365 or disabled (equal to -1)
		ipl_remediate
		# Check if remediation was successful
		ipl_chk
		if [ "$?" != "102" ]; then
			test2=remediated
		fi
	fi
	# Check testing results
	if [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi
	# Check if test should be set to manual instead
	if [ -z "$(awk -F : '/^root:[^!*]/ {print $7}' /etc/shadow)" ] || [ "$(awk -F : '/^root:[^!*]/ {print $7}' /etc/shadow)" -gt "30" ] || [ "$(awk -F : '/^root:[^!*]/ {print $7}' /etc/shadow)" = "-1" ]; then
		if [ "$(date --date="$(chage --list root | grep '^Password inactive' | cut -d: -f2)" +%s)" -le "$((cde-1987200))" ]; then
			echo "the root account needs to be logged into before setting inactive_password_lock." | tee -a "$LOG" 2>> "$ELOG"
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
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}