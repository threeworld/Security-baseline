#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_access_su_command_restricted.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/24/20    Recommendation "Ensure access to the su command is restricted"
# 
fed_ensure_access_su_command_restricted()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	if grep -Eqs '^\s*auth\s+required\s+pam_wheel.so\s+([^#]+\s+)?use_uid\b' /etc/pam.d/su; then
		test1=passed
	else
		if grep -Eqs '^\s*(#\s*)?auth\s+required\s+pam_wheel.so' /etc/pam.d/su; then
			sed -ri 's/^\s*(#\s*)?(auth\s+required\s+pam_wheel.so\s+)(.*)$/\2use_uid \3/' /etc/pam.d/su
		else
			sed -ri '/^\s*(#\s*)?auth\s+substack\s+system-auth\b.*$/ i auth            required        pam_wheel.so use_uid' /etc/pam.d/su
		fi
		grep -Eqs '^\s*auth\s+required\s+pam_wheel.so\s+([^#]+\s+)?use_uid\b' /etc/pam.d/su && test1=remediated
	fi
	grep -Eqs '^wheel:[^:]+:[^:]+:' /etc/group && test2=passed || test2=manual
	if [ "$test1" = manual ] || [ "$test2" = manual ]; then
		test=manual
	elif [ -n "$test1" ] && [ -n "$test2" ]; then
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