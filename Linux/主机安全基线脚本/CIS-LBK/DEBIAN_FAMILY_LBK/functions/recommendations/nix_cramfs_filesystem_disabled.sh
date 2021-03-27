#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_cramfs_filesystem_disabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       12/01/20    Recommendation "Ensure mounting of cramfs filesystems is disabled"
# 
cramfs_filesystem_disabled()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""

	XCCDF_VALUE_REGEX="cramfs"

	km_loadable_chk()
	{
		tst=$(modprobe -n -v "$XCCDF_VALUE_REGEX" | grep -E "($XCCDF_VALUE_REGEX|install)")
		echo "$tst" | grep -Eq "^\s*install\s+\/bin\/(true|false)\b" && return "${XCCDF_RESULT_PASS:-101}" || return "${XCCDF_RESULT_FAIL:-102}"
	}
	km_loaded_chk()
	{
		! lsmod | grep "$XCCDF_VALUE_REGEX" && return "${XCCDF_RESULT_PASS:-101}" || return "${XCCDF_RESULT_FAIL:-102}"
	}

	if [ -z "$(modprobe -n -v "$XCCDF_VALUE_REGEX")" ]; then
		test=NA
	else
		# Check if loadable
		echo "- $(date +%d-%b-%Y' '%T) - $XCCDF_VALUE_REGEX kernel module exists on the system" | tee -a "$LOG" 2>> "$ELOG"
		km_loadable_chk
		if [ "$?" = 101 ]; then
			echo "- $(date +%d-%b-%Y' '%T) - $XCCDF_VALUE_REGEX isn't loadable" | tee -a "$LOG" 2>> "$ELOG"
			test1=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - $XCCDF_VALUE_REGEX is loadable - remediating" | tee -a "$LOG" 2>> "$ELOG"
			echo "install $XCCDF_VALUE_REGEX /bin/true" >> /etc/modprobe.d/"$XCCDF_VALUE_REGEX".conf
			km_loadable_chk
			[ "$?" = 101 ] && test1=remediated
		fi
		# Check if loaded
		km_loaded_chk
		if [ "$?" = 101 ]; then
			echo "- $(date +%d-%b-%Y' '%T) - $XCCDF_VALUE_REGEX isn't loaded" | tee -a "$LOG" 2>> "$ELOG"
			test2=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - $XCCDF_VALUE_REGEX is loaded - remediating" | tee -a "$LOG" 2>> "$ELOG"
			rmmod "$XCCDF_VALUE_REGEX"
			km_loaded_chk
			[ "$?" = 101 ] && test2=remediated
		fi
		# Check status of tests
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
			echo "Recommendation \"$RNA\" Kernel module not on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}