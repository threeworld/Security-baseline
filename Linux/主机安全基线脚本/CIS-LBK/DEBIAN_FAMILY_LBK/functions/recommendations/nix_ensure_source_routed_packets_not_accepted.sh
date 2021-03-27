#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_source_routed_packets_not_accepted.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/22/20    Recommendation "Ensure source routed packets are not accepted"
# Eric Pinnell       11/12/20    Modified "Updated tests to use sub-functions"
#
ensure_source_routed_packets_not_accepted()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3="" test4="" test5="" test6="" test7="" test8=""
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
	src6_chk_fix()
	{
		# Check IPv6 kernel parameter in running config
		t1=""
		echo "- $(date +%d-%b-%Y' '%T) - Checking $syspar in the running config" | tee -a "$LOG" 2>> "$ELOG"
		if sysctl "$syspar" | grep -Eq "^$syspar\s*=\s*$spv\b"; then
		t1=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - Remediating $syspar in the running config" | tee -a "$LOG" 2>> "$ELOG"
			sysctl -w "$syspar"="$spv"
			sysctl -w net.ipv6.route.flush=1
			sysctl "$syspar" | grep -Eq "^$syspar\s*=\s*$spv\b" && t1=remediated
		fi
	}
	spif_chk_fix()
	{
		# Check kernel parameter in sysctl conf files
		t1=""
		echo "- $(date +%d-%b-%Y' '%T) - Checking $syspar in sysctl conf files" | tee -a "$LOG" 2>> "$ELOG"
		if grep -Elqs "^\s*$regpar\s*=\s*$spv\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && ! grep -Elqs "^\s*$regpar\s*=\s*$nspv" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf; then
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

	# Check net.ipv4.conf.all.accept_source_route
	# Check net.ipv4.conf.all.accept_source_route in the running config
	syspar="net.ipv4.conf.all.accept_source_route"
	regpar="net\.ipv4\.conf\.all\.accept_source_route"
	spv="0"
	src4_chk_fix
	test1=$t1
	# Check net.ipv4.conf.all.accept_source_route in sysctl conf files
	spif_chk_fix
	test2=$t1

	# Check net.ipv4.conf.default.accept_source_route
	# Check net.ipv4.conf.default.accept_source_route in the running config
	syspar="net.ipv4.conf.default.accept_source_route"
	regpar="net\.ipv4\.conf\.default\.accept_source_route"
	spv="0"
	src4_chk_fix
	test3=$t1
	# Check net.ipv4.conf.all.secure_redirects in sysctl conf files
	spif_chk_fix
	test4=$t1

	# Check if IPv6 is enabled on the system
	[ -z "$no_ipv6" ] && ipv6_chk
	if [ "$no_ipv6" = yes ]; then
		echo "- $(date +%d-%b-%Y' '%T) - IPv6 is disabled, skipping IPv6 checks" | tee -a "$LOG" 2>> "$ELOG"
		test5=passed test6=passed test7=passed test8=passed
	else
		# Check net.ipv6.conf.all.accept_source_route
		# Check net.ipv6.conf.all.accept_source_route in the running config
		syspar="net.ipv6.conf.all.accept_source_route"
		regpar="net\.ipv6\.conf\.all\.accept_source_route"
		spv="0"
		src6_chk_fix
		test5=$t1
		# Check net.ipv6.conf.all.accept_source_route conf files
		spif_chk_fix
		test6=$t1

		# Check net.ipv6.conf.default.accept_source_route
		# Check net.ipv6.conf.default.accept_source_route in the running config
		syspar="net.ipv6.conf.default.accept_source_route"
		regpar="net\.ipv6\.conf\.default\.accept_source_route"
		spv="0"
		src6_chk_fix
		test7=$t1
		# Check net.ipv6.conf.default.accept_source_route
		spif_chk_fix
		test8=$t1
	fi

	# Check status of tests
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ] && [ -n "$test5" ] && [ -n "$test6" ] && [ -n "$test7" ] && [ -n "$test8" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ] && [ "$test6" = passed ] && [ "$test7" = passed ] && [ "$test8" = passed ]; then
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