#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ssh7_ensure_strong_mac_algorithms_used.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/04/20    Recommendation "Ensure only strong MAC algorithms are used"
#
ssh7_ensure_strong_mac_algorithms_used()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	hn=$(hostname)
	ha=$(grep "$hn" /etc/hosts | awk '{print $1}')
	XCCDF_VALUE_REGEX="^\s*macs\s+([^#]+,)?(hmac-md5|hmac-md5-96|hmac-ripemd160|hmac-sha1|hmac-sha1-96|umac-64@openssh\.com|hmac-md5-etm@openssh\.com|hmac-md5-96-etm@openssh\.com|hmac-ripemd160-etm@openssh\.com|hmac-sha1-etm@openssh\.com|hmac-sha1-96-etm@openssh\.com|umac-64-etm@openssh\.com|umac-128-etm@openssh\.com)\b"
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
			grep -Eiq 'macs\b' /etc/ssh/sshd_config && sed -ri '/^\s*MACs\b/s/^/# /' /etc/ssh/sshd_config
			echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
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