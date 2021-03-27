#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_permissions_sshd_config_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure permissions on /etc/ssh/sshd_config are configured"
# 
ensure_permissions_sshd_config_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ openssh-server >/dev/null; then
		test=NA
	else
		if [ -f /etc/ssh/sshd_config ] && [ "$(stat -Lc "%A" /etc/ssh/sshd_config | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/ssh/sshd_config)" = "root root" ]; then
			test=passed
		else
			[ -f /etc/ssh/sshd_config ] && chmod u-x,og-rwx /etc/ssh/sshd_config && chown root:root /etc/ssh/sshd_config
			[ -f /etc/ssh/sshd_config ] && [ "$(stat -Lc "%A" /etc/ssh/sshd_config | cut -c4-10)" = "-------" ] && [ "$(stat -Lc "%U %G" /etc/ssh/sshd_config)" = "root root" ] && test=remediated
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
		NA)
			echo "Recommendation \"$RNA\" openssh-server not installed - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}