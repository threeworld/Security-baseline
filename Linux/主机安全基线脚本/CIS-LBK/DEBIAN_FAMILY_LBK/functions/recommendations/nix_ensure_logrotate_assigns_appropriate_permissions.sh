#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_logrotate_assigns_appropriate_permissions.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/20/20    Recommendation "Ensure logrotate assigns appropriate permissions"
# 
ensure_logrotate_assigns_appropriate_permissions()
{
	test=""
	if grep -Eq "^\s*create\s+\S+" /etc/logrotate.conf && ! grep -E "^\s*create" /etc/logrotate.conf | grep -Evq "\s(0)?[0-6][04]0\s"; then
		test=passed
	else
		if grep -Eq '^\s*create\b' /etc/logrotate.conf; then
			sed -ri 's/^\s*create(\s+[0-9]?[0-9][0-9][0-9])?(\s*.*)$/create 0640 \2/' /etc/logrotate.conf
			if grep -Eq "^\s*create\s+\S+" /etc/logrotate.conf && ! grep -E "^\s*create" /etc/logrotate.conf | grep -Evq "\s(0)?[0-6][04]0\s"; then
				test=remediated
			fi
		else
			echo "create 0640" /etc/logrotate.conf
			if grep -Eq "^\s*create\s+\S+" /etc/logrotate.conf && ! grep -E "^\s*create" /etc/logrotate.conf | grep -Evq "\s(0)?[0-6][04]0\s"; then
				test=remediated
			fi
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
		NA)
			echo "Recommendation \"$RNA\" Another firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}