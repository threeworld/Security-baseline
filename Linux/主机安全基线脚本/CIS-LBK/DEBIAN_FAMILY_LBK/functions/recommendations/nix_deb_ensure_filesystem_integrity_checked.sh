#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_filesystem_integrity_checked.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation: "Ensure filesystem integrity is regularly checked"
# 
deb_ensure_filesystem_integrity_checked()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" ccr="" stc=""

	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi

	cron_check()
	{
		# Check if done with cron
		t1=""
		if $PQ cron >/dev/null; then
			echo "- $(date +%d-%b-%Y' '%T) - Checking for filesystem integrity check job in cron" | tee -a "$LOG" 2>> "$ELOG"
			grep -Esq '^\s*aide\.wrapper\s+\$AIDEARGS\s+\"--\$COMMAND\"\s*' /etc/cron.daily/* && t1=passed
			if [ "$t1" != passed ]; then
				for file in /var/spool/cron/root /etc/crontab /etc/cron.d/*; do
					grep -Esq '^([-0-9*\/,A-Za-z]+\s+){5}\/usr\/bin/aide\.wrapper\s--config\s+\/etc\/aide\/aide\.conf\s--check\b' "$file" && t1=passed
				done
			fi
			if [ "$t1" != passed ]; then
				for file in /etc/cron.hourly/* /etc/cron.daily/* /etc/cron.weekly/* /etc/cron.monthly/*; do
					grep -Esq '^\s*\/usr\/bin/aide\.wrapper\s--config\s+\/etc\/aide\/aide\.conf\s--check\b' "$file" && t1=passed
				done
			fi
		fi
		if [ "$t1" = passed ]; then
			return "${XCCDF_RESULT_PASS:-101}"
		else
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}
	systemd_timers_check()
	{
		# Check if done with systemd timers
		t1=""
		echo "- $(date +%d-%b-%Y' '%T) - Checking for filesystem integrity check job in systemd timers" | tee -a "$LOG" 2>> "$ELOG"
		if systemctl is-enabled aidecheck.service | grep -q 'enabled' && systemctl is-enabled aidecheck.timer | grep -q 'enabled' && systemctl status aidecheck.timer | grep -Eq '^\s*Active:\s+active\s+(\(running\)|\(exited\))'; then
			t1=passed
		fi
		if [ "$t1" = passed ]; then
			return "${XCCDF_RESULT_PASS:-101}"
		else
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}

	# remediate if required
	cron_check
	ccr="$?"
	if [ "$ccr" = "101" ]; then
		test=passed
	else
		systemd_timers_check
		stc="$?"
		[ "$stc" = "101" ] && test=passed
	fi

	if [ "$test" != "passed" ]; then
		if $PQ cron >/dev/null; then
			echo "- $(date +%d-%b-%Y' '%T) - Remediating \"$RNA\" - adding cron job" | tee -a "$LOG" 2>> "$ELOG"
			echo "0 5 * * * /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check" | crontab -u root -
			cron_check
			[ "$?" = "101" ] && test=remediated
		else
			echo "- $(date +%d-%b-%Y' '%T) - Remediating \"$RNA\" - adding systemd timers" | tee -a "$LOG" 2>> "$ELOG"
			[ -e /etc/systemd/system/aidecheck.service ] && rm -f /etc/systemd/system/aidecheck.service
			{
				echo "[Unit]"
				echo "Description=Aide Check"
				echo ""
				echo "[Service]"
				echo "Type=simple"
				echo "ExecStart=/usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"
				echo ""
				echo "[Install]"
				echo "WantedBy=multi-user.target"
			} >> /etc/systemd/system/aidecheck.service

			[ -e /etc/systemd/system/aidecheck.timer ] && rm -f /etc/systemd/system/aidecheck.timer
			{
				echo "[Unit]"
				echo "Description=Aide check every day at 5AM"
				echo ""
				echo "[Timer]"
				echo "OnCalendar=*-*-* 05:00:00"
				echo "Unit=aidecheck.service"
				echo ""
				echo "[Install]"
				echo "WantedBy=multi-user.target"
			} >> /etc/systemd/system/aidecheck.timer

			chown root:root /etc/systemd/system/aidecheck.*
			chmod 0644 /etc/systemd/system/aidecheck.*
			systemctl daemon-reload
			systemctl enable aidecheck.service
			systemctl --now enable aidecheck.timer
			systemd_timers_check
			[ "$?" = "101" ] && test=remediated
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
			echo "Recommendation \"$RNA\" Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}