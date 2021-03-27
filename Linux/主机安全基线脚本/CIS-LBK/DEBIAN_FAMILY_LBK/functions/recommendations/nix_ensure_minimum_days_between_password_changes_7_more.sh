#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_minimum_days_between_password_changes_7_more.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure minimum days between password changes is 7 or more"
# 
ensure_minimum_days_between_password_changes_7_more()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	# Sub function to check users for PASS_MIN_DAYS
	pmind_chk()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Starting check users for PASS_MIN_DAYS" | tee -a "$LOG" 2>> "$ELOG"
		awk -F : '/^[^:]+:[^!*]/ {print $4}' /etc/shadow | while read -r days; do
			[ -z "$days" ] && return "${XCCDF_RESULT_FAIL:-102}"
			if [ "$days" -lt "7" ] || [ "$days" = "-1" ]; then
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	# Sub function to remediate user's PASS_MIN_DAYS
	pmind_remediate()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Remediate users' PASS_MIN_DAYS" | tee -a "$LOG" 2>> "$ELOG"
		user="" days=""
		awk -F : '/^[^:]+:[^!*]/ {print $1 " " $4}' /etc/shadow | while read -r user days; do
			if [ -z "$days" ] || [ "$days" -lt "7" ] || [ "$days" = "-1" ]; then
				echo "User: \"$user\" has PASS_MIN_DAYS of: \"$days\", remediating user: \"$user\"" | tee -a "$LOG" 2>> "$ELOG"
				[ -n "$user" ] && chage --mindays 7 "$user"
			fi
		done
	}
	# Check if PASS_MIN_DAYS is configured in /etc/login.defs
	echo "- $(date +%d-%b-%Y' '%T) - Starting check if PASS_MIN_DAYS is configured in /etc/login.defs" | tee -a "$LOG" 2>> "$ELOG"
	if [ -n "$(grep '^\s*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')" ] && [ "$(grep '^\s*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')" -ge "7" ]; then
		test1=passed
	else
		grep -Eq 'PASS_MIN_DAYS\s+([0-9]|[1-9][0-9]+)\b' /etc/login.defs && sed -ri 's/^\s*(#\s*)?(PASS_MIN_DAYS\s+)([0-9]|[1-9][0-9]+)\b(.*)$/\27\4/' /etc/login.defs || echo "PASS_MIN_DAYS   7" >> /etc/login.defs
		[ -n "$(grep '^\s*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')" ] && [ "$(grep '^\s*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')" -ge "7" ] && test1=remediated
	fi
	# Check users for PASS_MIN_DAYS
	pmind_chk
	if [ "$?" != "102" ]; then
		test2=passed
	else
		# Remediate users with PASS_MIN_DAYS less than 7 or disabled (equal to -1)
		pmind_remediate
		# Check if remediation was successful
		pmind_chk
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