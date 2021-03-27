#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_nodev_tmp.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/08/20    Recommendation "Ensure nodev option set on /tmp partition"
# Eric Pinnell       11/24/20    Modified "Fixed bug in test"
# 
ensure_nodev_tmp()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# Check to see if partition exists
	if mount | grep -Eq '\s\/tmp\s'; then
		# check to see if /tmp is configured in /etc/fstab
		if grep -Eq '^\s*[^#]+\s+\/tmp\s' /etc/fstab; then
			echo "- $(date +%d-%b-%Y' '%T) - /tmp is configured in /etc/fstab" | tee -a "$LOG" 2>> "$ELOG"
			if ! grep -E '^\s*[^#]+\s+\/tmp\s' /etc/fstab | grep -vq 'nodev'; then
				test=passed
			else
				echo "- $(date +%d-%b-%Y' '%T) - remediating /tmp in /etc/fstab" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri 's/^\s*([^#]+\s+\/tmp\s+)(\S+\s+)(\S+)?(\s+[0-9]\s+[0-9].*)$/\1\2\3,nodev\4/' /etc/fstab
				! grep -E '^\s*[^#]+\s+\/tmp\s' /etc/fstab | grep -vq 'nodev' && test=remediated
				mount -o remount,noexec,nodev,nosuid /tmp
			fi
		elif [ -s /etc/systemd/system/local-fs.target.wants/tmp.mount ]; then
			echo "- $(date +%d-%b-%Y' '%T) - /tmp is configured in tmp.mount" | tee -a "$LOG" 2>> "$ELOG"
			if awk '/[Mount]/,0' /etc/systemd/system/local-fs.target.wants/tmp.mount | grep -Eq '^\s*Options=([^#]+,)?nodev'; then
				test=passed
			else
				echo "- $(date +%d-%b-%Y' '%T) - remediating /tmp in tmp.mount" | tee -a "$LOG" 2>> "$ELOG"
				sed -ri 's/(^\s*Options=[^#]+)/\1,nodev/' /etc/systemd/system/local-fs.target.wants/tmp.mount
				awk '/[Mount]/,0' /etc/systemd/system/local-fs.target.wants/tmp.mount | grep -Eq '^\s*Options=([^#]+,)?nodev' && test=remediated
				mount -o remount,noexec,nodev,nosuid /tmp
			fi
		fi
	else
		test=NA
	fi
	echo "- $(date +%d-%b-%Y' '%T) - Completed $RNA" | tee -a "$LOG" 2>> "$ELOG"

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
			echo "Recommendation \"$RNA\" Partition doesn't exist - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}