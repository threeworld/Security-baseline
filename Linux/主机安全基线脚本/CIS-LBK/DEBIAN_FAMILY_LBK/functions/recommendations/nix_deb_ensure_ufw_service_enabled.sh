#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_ufw_service_enabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/19/20    Recommendation "Ensure ufw service is enabled"
# 
deb_ensure_ufw_service_enabled()
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
		test1="" test2=""
		if systemctl is-enabled ufw | grep -q 'enabled'; then
			test1=passed
		else
			systemctl unmask ufw
			systemctl --now enable ufw
			systemctl is-enabled ufw | grep -q 'enabled' && test1=remediated
		fi
		if ufw status | grep -q 'Status: active'; then
			test2=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - enabling ufw - opening port 22 from and to any - Please update to site specific requirements!" | tee -a "$LOG" 2>> "$ELOG"
			ufw allow proto tcp from any to any port 22
			ufw --force enable
			ufw status | grep -q 'Status: active' && test2=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ]; then
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