#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_rsyslog_default_file_permissions_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure rsyslog default file permissions configured"
# 
ensure_rsyslog_default_file_permissions_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""

	# check if default file permissions are set correctly



	if grep -Eqs '^\s*\$[Ff]ile[Cc]reate[Mm]ode\s+0[6420][04]0\b' /etc/rsyslog.conf /etc/rsyslog.d/*.conf && ! grep -s '^\s*\$[Ff]ile[Cc]reate[Mm]ode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf | grep -Evq '0[0246][04]0'; then
		test=passed
	else
		if grep -s '^\s*\$[Ff]ile[Cc]reate[Mm]ode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf | grep -Evq '0[0246][04]0'; then
			grep '^\s*\$[Ff]ile[Cc]reate[Mm]ode' /etc/rsyslog.conf | grep -Evq '0[0246][04]0' && sed -ri 's/(^\s*)(\$[Ff]ile[Cc]reate[Mm]ode)(\s+)([0-9][0-9][0-9][0-9])(\s*)(\s*.*)?$/\1\2 0640 \5\6/' /etc/rsyslog.conf
			if [ -n "$(find /etc/rsyslog.d/ -name '*.conf' -type f)" ]; then
				for file in /etc/rsyslog.d/*.conf; do
					grep '^\s*\$[Ff]ile[Cc]reate[Mm]ode' "$file" | grep -Evq '0[0246][04]0' && sed -ri 's/(^\s*)(\$[Ff]ile[Cc]reate[Mm]ode)(\s+)([0-9][0-9][0-9][0-9])(\s*)(\s*.*)?$/\1\2 0640 \5\6/' "$file"
				done
			fi
		else
			! grep -Eqs '^\s*\$[Ff]ile[Cc]reate[Mm]ode\s+0[6420][04]0\b' /etc/rsyslog.conf && echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
		fi
		if grep -Eqs '^\s*\$[Ff]ile[Cc]reate[Mm]ode\s+0[6420][04]0\b' /etc/rsyslog.conf /etc/rsyslog.d/*.conf && ! grep -s '^\s*\$[Ff]ile[Cc]reate[Mm]ode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf | grep -Evq '0[0246][04]0'; then
			test=remediated
		fi
	fi
	echo "- $(date +%d-%b-%Y' '%T) - Completed $RNA" | tee -a "$LOG" 2>> "$ELOG"
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