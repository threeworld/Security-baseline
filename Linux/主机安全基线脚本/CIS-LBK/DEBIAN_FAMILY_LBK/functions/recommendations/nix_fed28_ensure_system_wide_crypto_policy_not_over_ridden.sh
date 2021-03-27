#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_system_wide_crypto_policy_not_over_ridden.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/23/20    Recommendation "Ensure system-wide crypto policy is not over-ridden"
# 
fed28_ensure_system_wide_crypto_policy_not_over_ridden()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ  openssh-server 2>>/dev/null; then
		test=NA
	else
		if ! sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'CRYPTO_POLICY\s*=' && ! grep -Eiq '^\s*([^#]+\s*)?CRYPTO_POLICY\s*=' /etc/ssh/sshd_config; then
			test=passed
		else
			grep -Eiq '^\s*CRYPTO_POLICY\s*=' /etc/ssh/sshd_config && sed -ri 's/^\s*CRYPTO_POLICY\s*=\s*/#&/' /etc/ssh/sshd_config
			systemctl reload sshd
			! sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'CRYPTO_POLICY\s*=' && ! grep -Eiq '^\s*([^#]+\s*)?CRYPTO_POLICY\s*=' /etc/ssh/sshd_config && test=remediated
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
			echo "Recommendation \"$RNA\" openssh-server not installed - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}