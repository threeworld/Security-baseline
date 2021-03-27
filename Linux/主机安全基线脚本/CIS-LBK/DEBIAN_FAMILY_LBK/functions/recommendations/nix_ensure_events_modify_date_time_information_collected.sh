#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_events_modify_date_time_information_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/01/20    Recommendation "Ensure events that modify date and time information are collected"
# 
ensure_events_modify_date_time_information_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	sysarch="" test="" test1="" test2="" test3="" test4="" t1="" t2=""

	# Check if system is 32 or 64 bit
	arch | grep -q "x86_64" && sysarch=b64 || sysarch=b32

	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(adjtimex,settimeofday|settimeofday,adjtimex)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+adjtimex\s+-S\s+settimeofday|-S\s+settimeofday\s+-S\s+adjtimex)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/50-time_change.rules
		# Check status for auditd rule
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(\2|\3))(stime|settimeofday|adjtimex),(?!(\1|\3))(stime|settimeofday|adjtimex),(?!(\1|\2))(stime|settimeofday|adjtimex)\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32(?!(\2|\3))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)(?!(\1|\3))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)(?!(\1|\2))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/50-time_change.rules
	# Check status for auditd rule
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""

	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S clock_settime -k time-change"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+clock_settime\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+clock_settime\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/50-time_change.rules
		# Check status for auditd rule
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S clock_settime -k time-change"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+clock_settime\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+clock_settime\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/50-time_change.rules
	# Check status for auditd rule
	[ "$t1" = passed ] && [ "$t2" = passed ] && test4=passed
	t1="" t2=""

	# Check rule "-w /etc/localtime -p wa -k time-change"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/localtime\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/50-time_change.rules
	# Check status for auditd rule
	[ "$t1" = passed ] && [ "$t2" = passed ] && test5=passed
	t1="" t2=""

	# Check results of checks
	if [ "$sysarch" = "b64" ]; then
		[ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && test=passed
	else 
		[ "$test2" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && test=passed
	fi
	if [ "$test" != passed ]; then
		# restart the auditd service
		service auditd restart

		# Check rule "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(\2|\3))(stime|settimeofday|adjtimex),(?!(\1|\3))(stime|settimeofday|adjtimex),(?!(\1|\2))(stime|settimeofday|adjtimex)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32(?!(\2|\3))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)(?!(\1|\3))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)(?!(\1|\2))(\s+-S\s+adjtimex|\s+-S\s+settimeofday|\s+-S\s+stime)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Check status for auditd rule
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""

		# Check rule "-a always,exit -F arch=b32 -S clock_settime -k time-change"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+clock_settime\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+clock_settime\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Check status for auditd rule
		[ "$t1" = passed ] && [ "$t2" = passed ] && test4=remediated
		t1="" t2=""
		
		# Check rule "-w /etc/localtime -p wa -k time-change"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/localtime\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Check status for auditd rule
		[ "$t1" = passed ] && [ "$t2" = passed ] && test5=remediated
		t1="" t2=""

		if [ "$sysarch" = "b64" ]; then		
			# Check rule "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(adjtimex,settimeofday|settimeofday,adjtimex)\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+adjtimex\s+-S\s+settimeofday|-S\s+settimeofday\s+-S\s+adjtimex)\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Check status for auditd rule
			[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
			t1="" t2=""

			# Check rule "-a always,exit -F arch=b64 -S clock_settime -k time-change"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+clock_settime\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+clock_settime\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Check status for auditd rule
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
			t1="" t2=""
		fi

		# Test to see if remediation was successful
		if [ "$sysarch" = "b64" ]; then
			[ "$test1" = remediated ] && [ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test4" = remediated ] && [ "$test5" = remediated ] && test=remediated
		else 
			[ "$test2" = remediated ] && [ "$test4" = remediated ] && [ "$test5" = remediated ] && test=remediated
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