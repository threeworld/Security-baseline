#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_ssh_idle_timeout_interval_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/23/20    Recommendation "Ensure SSH Idle Timeout Interval is configured"
# 
fed28_ensure_ssh_idle_timeout_interval_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	test1=""
	test2=""
	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ openssh-server >/dev/null ; then
		test=NA
	else
		if sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'ClientAliveInterval\s([1-9]|[1-9][0-9]|[0-2][0-9][0-9]|300)'; then
			test1=passed
		else
			grep -iq 'ClientAliveInterval' /etc/ssh/sshd_config && sed -ri 's/^\s*(#\s*)?([Cc]lient[Aa]live[Ii]nterval)(\s+\S+\s*)(\s+#.*)?$/\2 300\4/' /etc/ssh/sshd_config || echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
			sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'ClientAliveInterval\s([1-9]|[1-9][0-9]|[0-2][0-9][0-9]|300)' && test1=remediated
		fi
		if sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'ClientAliveCountMax\s[0-3]'; then
			test2=passed
		else
			grep -iq 'ClientAliveCountMax' /etc/ssh/sshd_config && sed -ri 's/^\s*(#\s*)?([Cc]lient[Aa]live[Cc]ount[Mm]ax)(\s+\S+\s*)(\s+#.*)?$/\2 0\4/' /etc/ssh/sshd_config || echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
			sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep "$(hostname)" /etc/hosts | awk '{print $1}')" | grep -Eiq 'ClientAliveCountMax\s[0-3]' && test2=remediated
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
			echo "Recommendation \"$RNA\" openssh-server not installed - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}