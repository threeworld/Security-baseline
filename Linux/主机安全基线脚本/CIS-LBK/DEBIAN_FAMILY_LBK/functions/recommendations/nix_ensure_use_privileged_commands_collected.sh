#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_use_privileged_commands_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/05/20    Recommendation "Ensure use of privileged commands is collected"
#

ensure_use_privileged_commands_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	# Check UID_MIN for the system
	umin=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

	# Check running config for rules
	for file in $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f); do
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-S\s+all\s+-F\s+path=$file\s+-F\s+perm=x\s+-F\s+auid>=$umin\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		if auditctl -l | grep -Eqs -- "$XCCDF_VALUE_REGEX"; then
			[ "$test1" != failed ] && test1=passed
		else
			test1=failed
		fi
	done

	# Check rules files for rules
	for file in $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f); do
		rule="-a always,exit -S all -F path=$file -F perm=x -F auid>=$umin -F auid!=4294967295 -k privileged"
		rfile="$(echo $file | sed 's/\//\\\//g')"
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-S\s+all\s+-F\s+path=$rfile\s+-F\s+perm=x\s+-F\s+auid>=$umin\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		if grep -Eqs -- "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules; then
			[ "$test2" != failed ] && test2=passed
		else
			test2=failed
			echo "$rule" >> /etc/audit/rules.d/50-privileged.rules
		fi
	done

	# Check results of checks
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		# re-start auditd
		service auditd restart
		# Wait to ensure auditd has re-started fully (Errors may result otherwise)
		sleep 10
		# Ensure test variables are cleared
		test1="" test2=""
		#re-check for rules

		# Check running config for rules
		for file in $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f); do
			XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-S\s+all\s+-F\s+path=$file\s+-F\s+perm=x\s+-F\s+auid>=$umin\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
			if auditctl -l | grep -Eqs -- "$XCCDF_VALUE_REGEX"; then
				[ "$test1" != failed ] && test1=remediated
			else
				test1=failed
			fi
		done

		# Check rules files for rules
		for file in $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f); do
			rfile="$(echo $file | sed 's/\//\\\//g')"
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-S\s+all\s+-F\s+path=$file\s+-F\s+perm=x\s+-F\s+auid>=$umin\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
			if grep -Eqs -- "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules; then
				[ "$test2" != failed ] && test2=remediated
			else
				test2=failed
			fi
		done

		# Check to see if remediation was successful
		[ "$test1" = remediated ] && [ "$test2" = remediated ] && test=remediated
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