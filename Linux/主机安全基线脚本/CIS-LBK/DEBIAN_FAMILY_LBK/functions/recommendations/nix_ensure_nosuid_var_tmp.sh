#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_nosuid_var_tmp.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/10/20    Recommendation "Ensure nosuid option set on /var/tmp partition"
# 
ensure_nosuid_var_tmp()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	if mount | grep -Eq '\s\/var\/tmp\s'; then
		if grep -Eq '^\s*[^#]+\s+\/var\/tmp\s+' /etc/fstab; then
			if ! grep -E '^\s*[^#]+\s+\/var\/tmp\s+' /etc/fstab | grep -vq 'nosuid'; then
				test=passed
			else
				sed -ri 's/^\s*([^#]+\s+\/var\/tmp\s+)(\S+\s+)(\S+)?(\s+[0-9]\s+[0-9].*)$/\1\2\3,nosuid\4/' /etc/fstab
				mount -o remount,noexec,nodev,nosuid /var/tmp
				! grep -E '^\s*[^#]+\s+\/var\/tmp\s+' /etc/fstab | grep -vq 'nosuid' && test=remediated
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