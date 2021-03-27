#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_default_deny_firewall_policy.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/19/20    Recommendation "Ensure default deny firewall policy"
# Eric Pinnell       11/30/20    Modified - Added allow out for ports 80 and 443
# 
deb_ensure_default_deny_firewall_policy()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check if UncomplicatedFirewall (ufw) is the firewall being used
	if [ -z "$FWIN" ]; then
		deb_firewall_chk
	fi
	if [ "$FWIN" != "UFw" ]; then
		test=NA
	else
		test1="" test2="" test3=""
		if ufw status verbose | grep -Eq "^Default:\s+(deny|reject)\s+\(incoming\),\s"; then
			test1=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - remediating ufw, setting incomming to default deny" | tee -a "$LOG" 2>> "$ELOG"
			echo "- $(date +%d-%b-%Y' '%T) - setting \"ufw allow proto tcp from any to any port 22\"" | tee -a "$LOG" 2>> "$ELOG"
			ufw allow proto tcp from any to any port 22
			echo "- $(date +%d-%b-%Y' '%T) - setting \"ufw allow git\"" | tee -a "$LOG" 2>> "$ELOG"
			ufw allow git
			echo "- $(date +%d-%b-%Y' '%T) - setting \"ufw logging on\"" | tee -a "$LOG" 2>> "$ELOG"
			ufw logging on
			ufw default deny incoming
			ufw status verbose | grep -Eq "^Default:\s+(deny|reject)\s+\(incoming\),\s" && test1=remediated
		fi
		if ufw status verbose | grep -Eq "^Default:\s+([^#]+,\s+)?(deny|reject)\s+\(outgoing\),\s+"; then
			test2=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - remediating ufw, setting outgoing to default deny" | tee -a "$LOG" 2>> "$ELOG"
			echo "- $(date +%d-%b-%Y' '%T) - setting \"ufw allow out 53\"" | tee -a "$LOG" 2>> "$ELOG"
			# Allow DNS Outbount
			ufw allow out 53
			# Allow http Outbound
			ufw allow out 80
			# Allow https outbound
			ufw allow out 443
			ufw default deny outgoing
			ufw status verbose | grep -Eq "^Default:\s+([^#]+,\s+)?(deny|reject)\s+\(outgoing\),\s+" && test2=remediated
		fi
		if ufw status verbose | grep -Eq "^Default:\s+([^#]+,\s+)?(disabled|deny|reject)\s+\(routed\)"; then
			test3=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - remediating ufw, routed to default deny" | tee -a "$LOG" 2>> "$ELOG"
			ufw default deny routed
			ufw status verbose | grep -Eq "^Default:\s+([^#]+,\s+)?(disabled|deny|reject)\s+\(routed\)" && test3=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
				test=passed
			else
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