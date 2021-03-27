#!/usr/bin/env sh
#
# CIS-LBK check function
# ~/CIS-LBK/functions/general/nix_auditd_privilieged_commands_file.sh
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell  10/05/20   Check auditd rules files for rules matching regex

auditd_privilieged_commands_file()
{
	test=""
	# Check UID_MIN for the system
	umin=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

	for file in $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f); do
		rule=$(echo $file | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>='"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' -F auid!=4294967295 -k privileged" }')
		XCCDF_VALUE_REGEX=$(echo $file | awk '{print "^\s*-a\s+(always,exit|exit,always)\s+-F\s+path=" $1 "\s+-F\s+perm=x\s+-F\s+auid>='"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"'\s+-F\s+auid!=4294967295\s+-k\s+\S+\b" }')
		if grep -Eqs "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules; then
			[ -z "$test2" ] && test2=passed
		else
			echo "$rule" >> /etc/audit/rules.d/50-privileged.rules
		fi
	done




	find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>='"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' -F auid!=4294967295 -k" }' | ( while read -r line; do
		if grep -E "^$line\s+\S+ *$" /etc/audit/rules.d/*.rules; then
			[ "$test" != failed ] && test=passed || test=failed
		else
			test=failed
		fi
	done

	# If the regex matched, output would be generated.  If so, we pass
	if [ "$test" = passed ] ; then
	    return "${XCCDF_RESULT_PASS:-101}"
	else
	    # print the reason why we are failing
	    echo "Missing auditd rules."
	    return "${XCCDF_RESULT_FAIL:-102}"
	fi
	)
}
nix_auditd()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting nix_auditd.sh" | tee -a "$LOG" 2>> "$ELOG"
	if echo "$XCCDF_VALUE_REGEX" | grep -Pq -- 'auid(>|>=|=>)'; then
		sysuid="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"
		REGEXCHK="$(echo "$XCCDF_VALUE_REGEX" | sed -r "s/^(.*)(auid(>=|>)\S+)(\s+-[A-Z].*)$/\1auid\3$sysuid\4/")"
		output="$(auditctl -l | grep -Ps -- "$REGEXCHK")"
	else
		output="$(auditctl -l | grep -Ps -- "$XCCDF_VALUE_REGEX")"
	fi

	# If the regex matched, output would be generated.  If so, we pass
	if [ -n "$output" ] ; then
		echo "audit rule: \"$output\" exists in the running auditd config" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	else
		# print the reason why we are failing
		if [ -n "$REGEXCHK" ] ; then
			echo "No auditd rules were found matching the regular expression: $REGEXCHK" | tee -a "$LOG" 2>> "$ELOG"
		else
			echo "No auditd rules were found matching the regular expression: $XCCDF_VALUE_REGEX" | tee -a "$LOG" 2>> "$ELOG"
		fi
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}