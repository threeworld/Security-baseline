#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_nodev_dev_shm.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure nodev option set on /dev/shm partition"
# 
ensure_nodev_dev_shm()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if mount | grep -Eq '\s/dev/shm\s'; then
		if grep -E '^\s*[^#]+\s+/dev/shm\s+' /etc/fstab; then
			if [ -z "$(grep -E '^\s*[^#]+\s+/dev/shm\s+' /etc/fstab | grep -v 'nodev')" ]; then
				test=passed
			else
				sed -ri '/s/^\s*([^#]+\s+\/var\/tmp\s*\S+\s+)([^#]*)?(\s+[0-9]\s+[0-9])/\1\2,nodev\3' /etc/fstab
				mount -o remount,noexec,nodev,nosuid /dev/shm
				[ -z "$(grep -E '^\s*[^#]+\s+/dev/shm\s+' /etc/fstab | grep -v 'nodev')" ] && [ -z "$(mount | grep -E '\s/dev/shm\s' | grep -v nodev)" ] && test=remediated
			fi
		else
			test=manual
		fi
	else
		test=NA
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
			echo "Recommendation \"$RNA\" Partition doesn't exist - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}