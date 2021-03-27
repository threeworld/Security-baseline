#!/usr/bin/env sh
#
# CIS-LBK check function
# ~/CIS-LBK/functions/general/nix_auditd_uid_file_v3.sh
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell  10/01/20   Check /etc/audit/rules.d/*.rules files for rules matching "advanced (-P)" regex

nix_auditd_uid_file_v3()
{
    echo "- $(date +%d-%b-%Y' '%T) - Starting nix_auditd_uid_file_v3" | tee -a "$LOG" 2>> "$ELOG"

    if echo "$XCCDF_VALUE_REGEX" | grep -Pq -- 'auid(>|>=|=>)'; then
    	sysuid="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"
    	REGEXCHK="$(echo "$XCCDF_VALUE_REGEX" | sed -r "s/^(.*)(auid(>=|>)\S+)(\s+-[A-Z].*)$/\1auid\3$sysuid\4/")"
    	output="$(grep -Ps -- "$REGEXCHK" /etc/audit/rules.d/*.rules | cut -d: -f2)"
    	location="$(grep -Ps -- "$REGEXCHK" /etc/audit/rules.d/*.rules | cut -d: -f1)"
    else
    	output="$(grep -Ps -- "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules | cut -d: -f2)"
    	location="$(grep -Ps -- "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules | cut -d: -f1)"
    fi

    # If the regex matched, output would be generated.  If so, we pass
    if [ -n "$output" ] ; then
    	echo "audit rule: $output exists in $location" | tee -a "$LOG" 2>> "$ELOG"
        return "${XCCDF_RESULT_PASS:-101}"
    else
        # print the reason why we are failing
        if [ -n "$REGEXCHK" ] ; then
        	echo "No auditd rules were found matching the regular expression: $REGEXCHK in any /etc/audit/rules.d/*.rules file" | tee -a "$LOG" 2>> "$ELOG"
#            echo "REGEXCHK is: \"$REGEXCHK\"" | tee -a "$LOG" 2>> "$ELOG"
#            echo "XCCDF_VALUE_REGEX is: \"$XCCDF_VALUE_REGEX\"" | tee -a "$LOG" 2>> "$ELOG"
        else
        	echo "No auditd rules were found matching the regular expression: $XCCDF_VALUE_REGEX in any /etc/audit/rules.d/*.rules file" | tee -a "$LOG" 2>> "$ELOG"
#            echo "REGEXCHK is: \"$REGEXCHK\"" | tee -a "$LOG" 2>> "$ELOG"
#            echo "XCCDF_VALUE_REGEX is: \"$XCCDF_VALUE_REGEX\"" | tee -a "$LOG" 2>> "$ELOG"
        fi
        return "${XCCDF_RESULT_FAIL:-102}"
    fi
}