#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_events_modify_systems_network_environment_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/05/20    Recommendation "Ensure events that modify the system's network environment are collected"
# Eric Pinnell       11/25/20    Modified "Corrected check for Fedora/Debian based rule"
# 
ensure_events_modify_systems_network_environment_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""  test3=""  test4=""  test5=""  test6="" t1="" t2=""

	# Check if system is 32 or 64 bit
	arch | grep -q "x86_64" && sysarch=b64 || sysarch=b32

	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(sethostname,setdomainname|setdomainname,sethostname)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+sethostname\s+-S\s+setdomainname|-S\s+setdomainname\s+-S\s+sethostname)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k {key name}"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(sethostname,setdomainname|setdomainname,sethostname)\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+(-S\s+sethostname\s+-S\s+setdomainname|-S\s+setdomainname\s+-S\s+sethostname)\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""

	# Check rule "-w /etc/issue -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/issue\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	t1="" t2=""

	# Check rule "-w /etc/issue.net -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/issue\.net\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test4=passed
	t1="" t2=""

	# Check rule "-w /etc/hosts -p wa -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/hosts\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test5=passed
	t1="" t2=""

	# Check rule: For Fedora based: "-w /etc/sysconfig/network -p wa -k {key name}" For Debian based: "-w /etc/network -p wa -k {key name}"
	if [ -d /etc/sysconfig/network ]; then
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sysconfig\/network\/?\s+-p\s+wa\s+-k\s+\S+\b"
		nfloc="/etc/sysconfig/network"
	elif [ -d /etc/network ]; then
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/network\/?\s+-p\s+wa\s+-k\s+\S+\b"
		nfloc="/etc/network"
	fi
	if [ -n "$XCCDF_VALUE_REGEX" ]; then
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-w $nfloc -p wa -k system-locale" >> /etc/audit/rules.d/50-system-locale.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test6=passed
		t1="" t2=""
	fi

	# Check results of checks
	if [ "$sysarch" = "b64" ]; then
		[ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && [ "$test6" = passed ] && test=passed
	else
		[ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && [ "$test6" = passed ] && test=passed
	fi
	if [ "$test" != passed ]; then
		# re-start auditd
		service auditd restart
		sleep 10
		#re-check for rules

		if [ "$sysarch" = "b64" ]; then
			# Check rule "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(sethostname,setdomainname|setdomainname,sethostname)\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+sethostname\s+-S\s+setdomainname|-S\s+setdomainname\s+-S\s+sethostname)\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
			t1="" t2=""
		fi

		# Check rule "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(sethostname,setdomainname|setdomainname,sethostname)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+(-S\s+sethostname\s+-S\s+setdomainname|-S\s+setdomainname\s+-S\s+sethostname)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""

		# Check rule "-w /etc/issue -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/issue\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		t1="" t2=""

		# Check rule "-w /etc/issue.net -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/issue\.net\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test4=remediated
		t1="" t2=""

		# Check rule "-w /etc/hosts -p wa -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/hosts\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test5=remediated
		t1="" t2=""

		# Check rule: For Fedora based: "-w /etc/sysconfig/network -p wa -k {key name}" For Debian based: "-w /etc/network -p wa -k {key name}"
		if [ -d /etc/sysconfig/network ]; then
			XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/sysconfig\/network\/?\s+-p\s+wa\s+-k\s+\S+\b"
		elif [ -d /etc/network ]; then
			XCCDF_VALUE_REGEX="^\s*-w\s+\/etc\/network\/?\s+-p\s+wa\s+-k\s+\S+\b"
		fi
		if [ -n "$XCCDF_VALUE_REGEX" ]; then
			# Check running auditd config for rule
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test6=remediated
			t1="" t2=""
		fi

		# Test to see if remediation was successful
		if [ "$sysarch" = "b64" ]; then
			[ "$test1" = remediated ] && [ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test4" = remediated ] && [ "$test5" = remediated ] && [ "$test6" = remediated ] && test=remediated
		else 
			[ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test4" = remediated ] && [ "$test5" = remediated ] && [ "$test6" = remediated ] && test=remediated
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