#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_broadcast_icmp_requests_ignored.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/21/20    Recommendation "Ensure broadcast ICMP requests are ignored"
# Eric Pinnell       11/12/20    Modified "Modified to use sub-functions"
#
ensure_broadcast_icmp_requests_ignored()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test1="" test2=""

	src4_chk_fix()
	{
		# Check IPv4 kernel parameter in running config
		t1=""
		echo "- $(date +%d-%b-%Y' '%T) - Checking $syspar in the running config" | tee -a "$LOG" 2>> "$ELOG"
		if sysctl "$syspar" | grep -Eq "^$syspar\s*=\s*$spv\b"; then
		t1=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - Remediating $syspar in the running config" | tee -a "$LOG" 2>> "$ELOG"
			sysctl -w "$syspar"="$spv"
			sysctl -w net.ipv4.route.flush=1
			sysctl "$syspar" | grep -Eq "^$syspar\s*=\s*$spv\b" && t1=remediated
		fi
	}

	spif_chk_fix()
	{
		# Check kernel parameter in sysctl conf files
		t1=""
		echo "- $(date +%d-%b-%Y' '%T) - Checking $syspar in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
		if grep -Elqs "^\s*$regpar\s*=\s*$spv\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
			t1=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - Remediating $syspar in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
			grep -Els "$regpar\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read -r filename; do
				sed -ri 's/^\s*(#\s*)?('"$regpar"'\s*=\s*)(\S+)(.*)?$/\2'"$spv"'/' "$filename"
			done
			if ! grep -Elqs "^\s*$regpar\s*=\s*$spv\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
				echo "$syspar = $spv" >> /etc/sysctl.d/cis_sysctl.conf
			fi
			grep -Elqs "^\s*$regpar\s*=\s*$spv\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && t1=remediated
		fi
	}

	# Check net.ipv4.icmp_echo_ignore_broadcasts
	# Check net.ipv4.icmp_echo_ignore_broadcasts in the running config
	syspar="net.ipv4.icmp_echo_ignore_broadcasts"
	regpar="net.ipv4.icmp_echo_ignore_broadcasts"
	spv="1"
	src4_chk_fix
	test1="$t1"
	# Check net.ipv4.icmp_echo_ignore_broadcasts in sysctl conf files
	spif_chk_fix
	test2="$t1"

	if [ -n "$test1" ] && [ -n "$test2" ]; then
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