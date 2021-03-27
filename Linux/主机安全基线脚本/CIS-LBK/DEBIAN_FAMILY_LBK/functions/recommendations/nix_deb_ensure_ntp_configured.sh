#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_ntp_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/20/20    Recommendation "Ensure ntp is configured"
#
deb_ensure_ntp_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3="" test4=""
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	if ! $PQ ntp >/dev/null; then
		test=NA
	else
		if grep -Pq '^\s*restrict\s+(-4\s+)?default\s+(?:[^#]+\s+)*(?!(?:\2|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\4))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/ntp.conf; then
			test1=passed
		else
			if grep -Eq '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf; then
				grep -E '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf | grep -vq 'kod\b' && sed -ri 's/(^\s*restrict\s+(-4\s+)?default\b([^#]+\s*)?)(\s*#.*)?$/\1 kod\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf | grep -vq 'nomodify\b' && sed -ri 's/(^\s*restrict\s+(-4\s+)?default\b([^#]+\s*)?)(\s*#.*)?$/\1 nomodify\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf | grep -vq 'notrap\b' && sed -ri 's/(^\s*restrict\s+(-4\s+)?default\b([^#]+\s*)?)(\s*#.*)?$/\1 notrap\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf | grep -vq 'nopeer\b' && sed -ri 's/(^\s*restrict\s+(-4\s+)?default\b([^#]+\s*)?)(\s*#.*)?$/\1 nopeer\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+(-4\s+)?default\b' /etc/ntp.conf | grep -vq 'noquery\b' && sed -ri 's/(^\s*restrict\s+(-4\s+)?default\b([^#]+\s*)?)(\s*#.*)?$/\1 noquery\4/' /etc/ntp.conf
			else
				echo "restrict -4 default kod nomodify notrap nopeer noquery" >> /etc/ntp.conf
			fi
			grep -Pq '^\s*restrict\s+(-4\s+)?default\s+(?:[^#]+\s+)*(?!(?:\2|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\4))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/ntp.conf && test1=remediated
		fi
		if grep -Pq '^\s*restrict\s+-6\s+default\s+(?:[^#]+\s+)*(?!(?:\2|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\4))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/ntp.conf; then
			test2=passed
		else
			if grep -Eq '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf; then
				grep -E '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf | grep -vq 'kod\b' && sed -ri 's/(^\s*restrict\s+-6\s+default\b([^#]+\s*)?)(\s*#.*)?$/\1 kod\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf | grep -vq 'nomodify\b' && sed -ri 's/(^\s*restrict\s+-6\s+default\b([^#]+\s*)?)(\s*#.*)?$/\1 nomodify\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf | grep -vq 'notrap\b' && sed -ri 's/(^\s*restrict\s+-6\s+default\b([^#]+\s*)?)(\s*#.*)?$/\1 notrap\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf | grep -vq 'nopeer\b' && sed -ri 's/(^\s*restrict\s+-6\s+default\b([^#]+\s*)?)(\s*#.*)?$/\1 nopeer\4/' /etc/ntp.conf
				grep -E '^\s*restrict\s+-6\s+default\b' /etc/ntp.conf | grep -vq 'noquery\b' && sed -ri 's/(^\s*restrict\s+-6\s+default\b([^#]+\s*)?)(\s*#.*)?$/\1 noquery\4/' /etc/ntp.conf
			else
				echo "restrict -6 default kod nomodify notrap nopeer noquery" >> /etc/ntp.conf
			fi
			grep -Pq '^\s*restrict\s+-6\s+default\s+(?:[^#]+\s+)*(?!(?:\2|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\3|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\4|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\5))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s+(?:[^#]+\s+)*(?!(?:\1|\2|\3|\4))(\s*\bkod\b\s*|\s*\bnomodify\b\s*|\s*\bnotrap\b\s*|\s*\bnopeer\b\s*|\s*\bnoquery\b\s*)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/ntp.conf && test2=remediated
		fi
		if grep -Eq '^(server|pool)' /etc/ntp.conf; then
			test3=passed
		else
			test=manual
		fi
#		if grep -Eq '^\s*OPTIONS\s*=\s*"([^"#]+\s+)?-u\sntp:ntp\b([^"#]+\s*)?"' /etc/sysconfig/ntpd || grep -Eq '^\s*ExecStart\s*=\s*([^#]+\s+)?-u\sntp:ntp\b' /usr/lib/systemd/system/ntpd.service; then
#		else
#			if grep -Eq '^\s*OPTIONS\s*=\s*' /etc/sysconfig/ntpd; then
#				sed -ri 's/(^\s*OPTIONS\s*=\s*)(\")?([^#"]+\s*)?(\")?(\s*#.*)?$/\1"\3 -u ntp:ntp\5/' /etc/sysconfig/ntpd
#			else
#				echo "OPTIONS=\"-u ntp:ntp\"" >> /etc/sysconfig/ntpd
#			fi
#			if grep -Eq '^\s*OPTIONS\s*=\s*"([^"#]+\s+)?-u\sntp:ntp\b([^"#]+\s*)?"' /etc/sysconfig/ntpd || grep -Eq '^\s*ExecStart\s*=\s*([^#]+\s+)?-u\sntp:ntp\b' /usr/lib/systemd/system/ntpd.service; then
#				test4=remediated
#			fi
#		fi

		if grep -q "RUNASUSER=ntp" /etc/init.d/ntp; then
			test4=passed
		else
			if grep-q "RUNASUSER=" /etc/init.d/ntp; then
				sed -ri 's/^\s*(#\s*)?(RUNASUSER=)(\S+)?(.*)$/\2ntp \3/' /etc/init.d/ntp
			else
				echo "RUNASUSER=ntp" >> /etc/init.d/ntp
			fi
			grep -q "RUNASUSER=ntp" /etc/init.d/ntp && test4=remediated
		fi
		if ! systemctl is-enabled systemd-timesyncd | grep -Eq '(enabled|disabled)'; then
			test5=passed
		else
			systemctl --now mask systemd-timesyncd
			! systemctl is-enabled systemd-timesyncd | grep -Eq '(enabled|disabled)' && test5=remediated
		fi
	fi

	if [ -z "$test" ]; then
		if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ] && [ -n "$test5" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ] && [ "$test5" = passed ]; then
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
			echo "Recommendation \"$RNA\" ntp is not installed on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}