#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_filesystem_integrity_checked.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/15/20    Recommendation "Ensure filesystem integrity is regularly checked"
# 
fed_ensure_filesystem_integrity_checked()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if crontab -u root -l | grep -Eq '^\s*[^#]+\s+([^#]+)?/aide\s--check'  || grep -Erqs '^\s*[^#]+\s+([^#]+)?/aide\s--check' /etc/cron.* /etc/crontab.d/* /etc/crontab; then
		test=passed
	elif grep -Eq '^\s*ExecStart=\/usr\/sbin\/aide\s--check\b' /etc/systemd/system/aidecheck.service && grep -Eq '^\s*Unit=aidecheck\.service\b' /etc/systemd/system/aidecheck.timer; then
		systemctl is-enabled aidecheck.service | grep -q enabled && systemctl is-enabled aidecheck.timer | grep -q enabled && test=passed
	else
		echo "0 5 * * * /usr/sbin/aide --check" | crontab -u root -
		if crontab -u root -l | grep -Eq '^\s*[^#]+\s+[^#]*/aide\s--check\b' || grep -Erqs '^\s*[^#]+\s+[^#]*/aide\s--check\b' /etc/cron.* /etc/crontab.d/* /etc/crontab; then
			test=remediated
		fi
	fi
	# Set return code and return
	if [ "$test" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	elif [ "$test" = remediated ]; then
		echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-103}" 
	else
		echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}