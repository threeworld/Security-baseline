#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_chrony_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/02/20    Recommendation "Ensure chrony is configured"
#
fed_chrony_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	if [ -z "$PQ" ] || [ -z "$PM" ]; then
		nix_package_manager_set
	fi
	if ! $PQ chrony >/dev/null; then
		test=NA
	else
		if grep -Eq '"^(server|pool)' /etc/chrony.conf; then
			test1=passed
		else
			test=manual
		fi
		if grep -Eq '^\s*OPTIONS\s*=\s*\"([^"#]+\s+)?-u\schrony\b([^"#]*)?"\s*(?:#.*)?$' /etc/sysconfig/chronyd; then
			test2=passed
		else
			if grep -q '^\s*OPTIONS\s*=\s*\'; then
				sed -ri 's/(^\s*OPTIONS\s*=\s*)(\")?(([^"#]+)?)(\")(.*)$/\1"-u chrony \3"\6/' /etc/sysconfig/chronyd
			else
				echo "OPTIONS=\"-u chrony\"" >> /etc/sysconfig/chronyd
			fi
			grep -Eq '^\s*OPTIONS\s*=\s*\"([^"#]+\s+)?-u\schrony\b([^"#]*)?"\s*(?:#.*)?$' /etc/sysconfig/chronyd && test2=remediated
		fi
	fi
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	elif [ "$test1" = passed ] && [ "$test2" = remediated ]; then
		test=remediated
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
			echo "Recommendation \"$RNA\" Chrony is not installed on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}