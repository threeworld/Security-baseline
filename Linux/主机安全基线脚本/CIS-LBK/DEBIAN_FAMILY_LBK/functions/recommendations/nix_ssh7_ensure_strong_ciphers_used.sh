#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ssh7_ensure_strong_ciphers_used.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/04/20    Recommendation "Ensure only strong Ciphers are used"
#
ssh7_ensure_strong_ciphers_used()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	hn=$(hostname)
	ha=$(grep "$hn" /etc/hosts | awk '{print $1}')
	XCCDF_VALUE_REGEX="^\s*ciphers\s+([^#]+,)?(3des-cbc|aes128-cbc|aes192-cbc|aes256-cbc|arcfour|arcfour128|arcfour256|blowfish-cbc|cast128-cbc|rijndael-cbc@lysator.liu.se)\b"
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check if openssh-server is installed
	if ! $PQ openssh-server >/dev/null; then
		test=NA
	else
		if echo "$XCCDF_VALUE_REGEX" | grep -Eq '^\^\\s\*'; then
			echo "$(sshd -T -C user=root -C host="$hn" -C addr="$ha" | grep -E "$(echo "$XCCDF_VALUE_REGEX" | cut -d'*' -f2 | cut -d'\' -f1)")" | tee -a "$LOG" 2>> "$ELOG"
		else
			echo "$(sshd -T -C user=root -C host="$hn" -C addr="$ha" | grep -E "$(echo "$XCCDF_VALUE_REGEX" | cut -d'\' -f1)")" | tee -a "$LOG" 2>> "$ELOG"
		fi

		if ! sshd -T -C user=root -C host="$hn" -C addr="$ha" | grep -Eq "$XCCDF_VALUE_REGEX"; then
			test=passed
		else
			grep -Eiq 'ciphers\b' /etc/ssh/sshd_config && sed -ri '/^\s*Ciphers\b/s/^/# /' /etc/ssh/sshd_config
			echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
			! sshd -T -C user=root -C host="$hn" -C addr="$ha" | grep -Eq "$XCCDF_VALUE_REGEX" && test=remediated
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
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}