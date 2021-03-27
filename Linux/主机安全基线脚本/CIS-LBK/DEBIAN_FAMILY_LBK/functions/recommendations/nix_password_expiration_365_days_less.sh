#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_password_expiration_365_days_less.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/28/20    Recommendation "Ensure password expiration is 365 days or less"
# 
password_expiration_365_days_less()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	cde="$(date "+%s")"
	test=""
	test1=""
	test2=""

	# Sub function to check users for PASS_MAX_DAYS
	pmd_chk()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Starting check users for PASS_MAX_DAYS" | tee -a "$LOG" 2>> "$ELOG"
		awk -F : '/^[^:]+:[^!*]/ {print $5}' /etc/shadow | while read -r days; do
			[ -z "$days" ] && return "${XCCDF_RESULT_FAIL:-102}"
			if [ "$days" -gt "365" ] || [ "$days" = "-1" ]; then
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	# Sub function to remediate user's PASS_MAX_DAYS
	pmd_remediate()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Remediate users' PASS_MAX_DAYS" | tee -a "$LOG" 2>> "$ELOG"
		user="" days=""
		awk -F : '/^[^:]+:[^!*]/ {print $1 " " $5}' /etc/shadow | while read -r user days; do
			if [ -z "$days" ] || [ "$days" -gt "365" ] || [ "$days" = "-1" ]; then
				echo "User: \"$user\" has PASS_MAX_DAYS of: \"$days\", remediating user: \"$user\"" | tee -a "$LOG" 2>> "$ELOG"
				if [ "$user" = "root" ]; then
					# Check if root's password is about to expire
					if [ "$(date --date="$(chage --list "$user" | grep '^Last password change' | cut -d: -f2)" +%s)" -le "$((cde-30758400))" ]; then
						echo "User \"$user\" password will be expired.  Please update root's password before setting password expiration for root" | tee -a "$LOG" 2>> "$ELOG"
					else
						chage --maxdays 365 "$user"
					fi
				else
					[ "$(date --date="$(chage --list "$user" | grep '^Last password change' | cut -d: -f2)" +%s)" -le "$((cde-31536000))" ] && echo "User \"$user\" password is more than 365 days old, users password may now be expired" | tee -a "$LOG" 2>> "$ELOG"
					[ -n "$user" ] && chage --maxdays 365 "$user"
				fi
			fi
		done
	}
	# Check if PASS_MAX_DAYS is configured in /etc/login.defs
	echo "- $(date +%d-%b-%Y' '%T) - Starting check if PASS_MAX_DAYS is configured in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
	if [ -n "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" ] && [ "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" -le "365" ] && [ "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" != "-1" ]; then
		test1=passed
	else
		echo "Updating /etc/login.defs  Setting PASS_MAX_DAYS to 365" | tee -a "$LOG" 2>> "$ELOG"
		grep -Eq 'PASS_MAX_DAYS\s+([1-9]|[1-9][0-9]+)\b' /etc/login.defs && sed -ri 's/^\s*(#\s*)?(PASS_MAX_DAYS\s+)([1-9]|[1-9][0-9]+)\b(.*)$/\2365\4/' /etc/login.defs || echo "PASS_MAX_DAYS   365" >> /etc/login.defs
		[ -n "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" ] && [ "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" -le "365" ] && [ "$(grep '^\s*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')" != "-1" ] && test1=remediated
	fi
	# Check users for PASS_MAX_DAYS
	pmd_chk
	if [ "$?" != "102" ]; then
		test2=passed
	else
		# Remediate users with PASS_MIN_DAYS greater than 365 or disabled (equal to -1)
		pmd_remediate
		# Check if remediation was successful
		pmd_chk
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
	if [ -z "$(awk -F : '/^root:[^!*]/ {print $5}' /etc/shadow)" ] || [ "$(awk -F : '/^root:[^!*]/ {print $5}' /etc/shadow)" -gt "365" ] || [ "$(awk -F : '/^root:[^!*]/ {print $5}' /etc/shadow)" = "-1" ]; then
		if [ "$(date --date="$(chage --list root | grep '^Last password change' | cut -d: -f2)" +%s)" -le "$((cde-30758400))" ]; then
			echo "the passwor for root needs to be updated before setting expiration.  Please updated root's password and set an expitation for root" | tee -a "$LOG" 2>> "$ELOG"
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