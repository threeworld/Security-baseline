#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_selinux_policy_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/24/20    Recommendation "Ensure SELinux policy is configured"
# 
fed_ensure_selinux_policy_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if grep -Eqs '^\s*SELINUXTYPE=(targeted|mls)\b' /etc/selinux/config && sestatus | grep -Eq 'Loaded\s+policy\s+name:\s+(targeted|mls)'; then
		test=passed
	else
		if grep -Eqs '^\s*SELINUXTYPE=\S+\b' /etc/selinux/config; then
			sed -ri 's/^\s*SELINUXTYPE=\S+\b.*$/# &/' /etc/selinux/config
			echo "SELINUXTYPE=targeted" >> /etc/selinux/config
		else
			echo "SELINUXTYPE=targeted" >> /etc/selinux/config
		fi
		grep -Eqs '^\s*SELINUXTYPE=(targeted|mls)\b' /etc/selinux/config && test=remediated
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