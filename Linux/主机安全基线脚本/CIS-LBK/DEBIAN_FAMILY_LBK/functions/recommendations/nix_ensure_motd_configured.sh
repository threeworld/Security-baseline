#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_motd_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/20/20    Recommendation "Ensure message of the day is configured properly"
# Eric Pinnell       11/25/20    Modified "Updated to use a case insensitive sed search and replace"
#
nix_ensure_motd_configured()
{
	# Ensure message of the day is configured properly
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	osr="$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')"
	if [ -z /etc/motd ] || ! grep -Eiq "(\\\v|\\\r|\\\m|\\\s|$osr)" /etc/motd; then
		test=passed
	else
		[ -n /etc/motd ] && sed -ri 's/(\\v|\\r|\\m|\\s|'"$osr"')//gI' /etc/motd
		if [ -z /etc/motd ] || ! grep -Eiq "(\\\v|\\\r|\\\m|\\\s|$osr)" /etc/motd; then
			test=remediated
		fi
	fi

#	sed -ri 's/(\\v|\\r|\\m|\\s)//g' /etc/motd

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