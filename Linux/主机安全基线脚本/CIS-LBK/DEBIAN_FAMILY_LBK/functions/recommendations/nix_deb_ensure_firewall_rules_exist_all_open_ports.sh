#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_firewall_rules_exist_all_open_ports.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/19/20    Recommendation "Ensure firewall rules exist for all open ports"
# Eric Pinnell       11/30/20    Modified - fixed bug in check
# 
deb_ensure_firewall_rules_exist_all_open_ports()
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
		port_configured_tst()
		{
			ss -4Hln | awk '($2=="LISTEN" && $5!~/127.0.0.1/ && $5!~/lo:/){ split($5,a,":"); print $1 " " a[2]}' | while read -r pcall pn; do
				! ufw status verbose | grep -E "^\s*$pn\/$pcall\s+ALLOW\s+IN\b" && return "${XCCDF_RESULT_FAIL:-102}"
			done
		}
		port_configured_fix()
		{
			ss -4Hln | awk '($2=="LISTEN" && $5!~/127.0.0.1/ && $5!~/lo:/){ split($5,a,":"); print $1 " " a[2]}' | while read -r pcall pn; do
				if ! ufw status verbose | grep -E "^\s*$pn\/$pcall\s+ALLOW\s+IN\b"; then
					# Open the port for listening ports in the firewall
					ufw allow in $pn/$pcall
				fi
			done
		}

		port_configured_tst
		if [ "$?" != "102" ]; then
			test=passed
		else
			port_configured_fix
			port_configured_tst
			[ "$?" != "102" ] && test=remediated
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