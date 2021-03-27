#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_kernel_module_loading_unloading_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    Recommendation "Ensure kernel module loading and unloading is collected"
# 
ensure_kernel_module_loading_unloading_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""  test3=""  test4=""  test5="" t1="" t2=""

	# Check if system is 32 or 64 bit
	arch | grep -q "x86_64" && sysarch=b64 || sysarch=b32

	# Check rule "-w /sbin/insmod -p x -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/insmod\/?\s+-p\s+x\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/rules.d/50-modules.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
	t1="" t2=""

	# Check rule "-w /sbin/rmmod -p x -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/rmmod\/?\s+-p\s+x\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/50-modules.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""

	# Check rule "-w /sbin/modprobe -p x -k {key name}"
	XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/modprobe\/?\s+-p\s+x\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/50-modules.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	t1="" t2=""

	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S init_module -S delete_module -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?:init_module,delete_module|delete_module,init_module)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+init_module\s+-S\s+delete_module|-S\s+delete_module\s+-S\s+init_module)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/rules.d/50-modules.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test4=passed
		t1="" t2=""
	fi

	if [ "$sysarch" = "b32" ]; then
		# Check rule "-a always,exit -F arch=b32 -S init_module -S delete_module -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?:init_module,delete_module|delete_module,init_module)\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+(-S\s+init_module\s+-S\s+delete_module|-S\s+delete_module\s+-S\s+init_module)\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S init_module -S delete_module -k modules" >> /etc/audit/rules.d/50-modules.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test5=passed
		t1="" t2=""
	fi

	# Check results of checks
	if [ "$sysarch" = "b64" ]; then
		[ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && test=passed
	elif [ "$sysarch" = "b32" ]; then
		[ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test5" = passed ]&& test=passed
	fi
	if [ "$test" != passed ]; then
		# re-start auditd
		service auditd restart
		sleep 10

		#re-check for rules

		# Check rule "-w /sbin/insmod -p x -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/insmod\/?\s+-p\s+x\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
		t1="" t2=""

		# Check rule "-w /sbin/rmmod -p x -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/rmmod\/?\s+-p\s+x\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""

		# Check rule "-w /sbin/modprobe -p x -k {key name}"
		XCCDF_VALUE_REGEX="^\s*-w\s+\/sbin\/modprobe\/?\s+-p\s+x\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		t1="" t2=""

		if [ "$sysarch" = "b64" ]; then
			# Check rule "-a always,exit -F arch=b64 -S init_module -S delete_module -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?:init_module,delete_module|delete_module,init_module)\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b64\s+(-S\s+init_module\s+-S\s+delete_module|-S\s+delete_module\s+-S\s+init_module)\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test4=remediated
			t1="" t2=""
		fi

		if [ "$sysarch" = "b32" ]; then
			# Check rule "-a always,exit -F arch=b32 -S init_module -S delete_module -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?:init_module,delete_module|delete_module,init_module)\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(always,exit|exit,always)\s+-F\s+arch=b32\s+(-S\s+init_module\s+-S\s+delete_module|-S\s+delete_module\s+-S\s+init_module)\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test5=remediated
			t1="" t2=""
		fi

		# Test to see if remediation was successful
		if [ "$sysarch" = "b64" ]; then
			[ "$test1" = remediated ] && [ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test4" = remediated ] && test=remediated
		elif [ "$sysarch" = "b32" ]; then
			[ "$test1" = remediated ] &&[ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test5" = remediated ] && test=remediated
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