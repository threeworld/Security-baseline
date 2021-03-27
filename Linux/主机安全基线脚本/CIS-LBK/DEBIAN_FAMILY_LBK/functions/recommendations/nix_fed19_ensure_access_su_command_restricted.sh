#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed19_ensure_access_su_command_restricted.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/24/20    Recommendation "Ensure access to the su command is restricted"
# 
fed19_ensure_access_su_command_restricted()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	test1="" test2="" gtc=""
	if grep -E '^\s*auth\s+required\s+pam_wheel\.so\s+(\S+\s+)*use_uid\s+(\S+\s+)*group=\S+\s*(\S+\s*)*(\s+#.*)?$' /etc/pam.d/su; then
		test1=passed
	else 
		grep -Es '^\s*(#\s*)?auth\s+required\s+pam_wheel.so' /etc/pam.d/su && sed -ri 's/^\s*(#\s*)?(auth\s+required\s+pam_wheel.so\s+)(.*)$/\2\3/' /etc/pam.d/su
		grep -Es '^\s*(#\s*)?auth\s+required\s+pam_wheel.so' /etc/pam.d/su | grep -vq 'use_uid' && sed -ri 's/^\s*(#\s*)?(auth\s+required\s+pam_wheel.so\s+)(.*)$/\2use_uid \3/' /etc/pam.d/su
		grep -Es '^\s*(#\s*)?auth\s+required\s+pam_wheel.so' /etc/pam.d/su | grep -Evq 'group=' && sed -ri 's/^\s*(#\s*)?(auth\s+required\s+pam_wheel.so\s+)(.*)$/\2\3 group=sugroup/' /etc/pam.d/su
		if grep -E '^\s*auth\s+required\s+pam_wheel\.so\s+(\S+\s+)*use_uid\s+(\S+\s+)*group=\S+\s*(\S+\s*)*(\s+#.*)?$' /etc/pam.d/su; then
			test1=remediated
		else
			sed -ri '/^\s*(#\s*)?auth\s+substack\s+system-auth\b.*$/ i auth            required        pam_wheel.so use_uid group=sugroup' /etc/pam.d/su
			grep -E '^\s*auth\s+required\s+pam_wheel\.so\s+(\S+\s+)*use_uid\s+(\S+\s+)*group=\S+\s*(\S+\s*)*(\s+#.*)?$' /etc/pam.d/su && test1=remediated
		fi
	fi
	gtc=$(grep -E '^\s*auth\s+required\s+pam_wheel\.so\s+' /etc/pam.d/su | sed -e 's/.*group=//;s/,? .*//')
	if [ -z "$gtc" ]; then
		test=manual
	else
		! grep -q "^$gtc" /etc/group && groupadd "$gtc"
		grep -Eqs "^$gtc:[^:]+:[^:]+:" /etc/group && test2=passed || test=manual
	fi

	if [ "$test" != manual ] && [ -n "$test1" ] && [ -n "$test2" ]; then
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