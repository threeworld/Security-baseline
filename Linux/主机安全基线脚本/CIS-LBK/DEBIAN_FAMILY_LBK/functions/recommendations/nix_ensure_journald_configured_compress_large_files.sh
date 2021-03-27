#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_journald_configured_compress_large_files.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure journald is configured to compress large log files"
# 
ensure_journald_configured_compress_large_files()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if grep -Eq '^\s*[Cc]ompress\s*=\s*yes\b' /etc/systemd/journald.conf; then
		test=passed
	else
		if grep -Eq '^\s*[Cc]ompress\s*=\s*' /etc/systemd/journald.conf; then
			sed -ri 's/(^\s*[Cc]ompress)(\s*=\s*\S+)(\s*.*)?$/\1=yes \3/' /etc/systemd/journald.conf
		else
			echo "Compress=yes" >> /etc/systemd/journald.conf
		fi
		grep -Eq '^\s*[Cc]ompress\s*=\s*yes\b' /etc/systemd/journald.conf && test=remediated
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