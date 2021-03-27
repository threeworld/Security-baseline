#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_ssh_warning_maxstartups_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/23/20    Recommendation "Ensure SSH MaxStartups is configured"
# 
ensure_ssh_warning_maxstartups_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ openssh-server >/dev/null ; then
		test=NA
	else
		if sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'MaxStartups\s(([1-9]|10):([1-9]|[1-2][0-9]|30):([1-9]|[1-5][0-9]|60))\b'; then
			test=passed
		else
			grep -iq 'MaxStartups' /etc/ssh/sshd_config && sed -ri 's/^\s*(#\s*)?([Mm]ax[Ss]tartups)(\s+\S+\s*)?(\s+#.*)?$/\2 10:30:60\4/' /etc/ssh/sshd_config || echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config
			sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'MaxStartups\s(([1-9]|10):([1-9]|[1-2][0-9]|30):([1-9]|[1-5][0-9]|60))\b' && test=remediated
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