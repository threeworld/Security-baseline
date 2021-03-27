#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_dac_permission_modification_events_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/05/20    Recommendation "Ensure discretionary access control permission modification events are collected"
# 
ensure_dac_permission_modification_events_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""  test3=""  test4=""  test5=""  test6="" t1="" t2=""

	# Check if system is 32 or 64 bit
	arch | grep -q "x86_64" && sysarch=b64 || sysarch=b32
	# Check UID_MIN for the system
	umin=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\2))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\2))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\2))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\2))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed
	t1="" t2=""


	if [ "$sysarch" = "b64" ]; then
		# Check rule "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\3))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\3))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\3))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\3))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test4=passed
	t1="" t2=""

	if [ "$sysarch" = "b64" ]; then
		# Check rule "a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\5))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\5))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test5=passed
		t1="" t2=""
	fi

	# Check rule "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k {key name}"
	# Check running auditd config for rule
	XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\5))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\5))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=$umin -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/50-perm_mod.rules
	# Test if audit rule passed
	[ "$t1" = passed ] && [ "$t2" = passed ] && test6=passed
	t1="" t2=""

	# Check results of checks
	if [ "$sysarch" = "b64" ]; then
		[ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && [ "$test6" = passed ] && test=passed
	else
		[ "$test2" = passed ] && [ "$test4" = passed ] && [ "$test6" = passed ] && test=passed
	fi
	if [ "$test" != passed ]; then
		# re-start auditd
		service auditd restart
		sleep 10
		#re-check for rules
		
		if [ "$sysarch" = "b64" ]; then
			# Check rule "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\2))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\2))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated
			t1="" t2=""
		fi

		# Check rule "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\3))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])(?!(?:\1|\2))(chmod[,\s]|fchmod[,\s]|fchmodat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\3))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)(?!(?:\1|\2))(-S\s+chmod\s+|-S\s+fchmod\s+|-S\s+fchmodat\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated
		t1="" t2=""


		if [ "$sysarch" = "b64" ]; then
			# Check rule "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\3))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\3))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
			t1="" t2=""
		fi

		# Check rule "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\3|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\4))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])(?!(?:\1|\2|\3))(chown[,\s]|fchown[,\s]|lchown[,\s]|fchownat[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\3|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\4))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)(?!(?:\1|\2|\3))(-S\s+chown\s+|-S\s+fchown\s+|-S\s+fchownat\s+|-S\s+lchown\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test4=remediated
		t1="" t2=""

		if [ "$sysarch" = "b64" ]; then
			# Check rule "a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k {key name}"
			# Check running auditd config for rule
			XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+-S\s+(?!(?:\2|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\5))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule
			XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b64\s+(?!(?:\2|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\5))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			# Test if audit rule passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test5=remediated
			t1="" t2=""
		fi

		# Check rule "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k {key name}"
		# Check running auditd config for rule
		XCCDF_VALUE_REGEX="^-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+-S\s+(?!(?:\2|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\3|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\4|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\5|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\6))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])(?!(?:\1|\2|\3|\4|\5))(setxattr[,\s]|lsetxattr[,\s]|fsetxattr[,\s]|removexattr[,\s]|lremovexattr[,\s]|fremovexattr[,\s])-F\s+auid>=1000\s+-F\s+auid!=-1\s+-F\s+key=\S+\b"
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		XCCDF_VALUE_REGEX="^\s*-a\s+(?:always,exit|exit,always)\s+-F\s+arch=b32\s+(?!(?:\2|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\3|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\4|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\5|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\6))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)(?!(?:\1|\2|\3|\4|\5))(-S\s+setxattr\s+|-S\s+lsetxattr\s+|-S\s+fsetxattr\s+|-S\s+removexattr\s+|-S\s+lremovexattr\s+|-S\s+fremovexattr\s+)-F\s+auid>=1000\s+-F\s+auid!=4294967295\s+-k\s+\S+\b"
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		# Test if audit rule passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test6=remediated
		t1="" t2=""

		# Test to see if remediation was successful
		if [ "$sysarch" = "b64" ]; then
			[ "$test1" = remediated ] && [ "$test2" = remediated ] && [ "$test3" = remediated ] && [ "$test4" = remediated ] && [ "$test5" = remediated ] && [ "$test6" = remediated ] && test=remediated
		else 
			[ "$test2" = remediated ] && [ "$test4" = remediated ] && [ "$test6" = remediated ] && test=remediated
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