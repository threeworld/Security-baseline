#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_no_duplicate_uid_exist.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/09/20    Recommendation "Ensure no duplicate UIDs exist"
# 
ensure_no_duplicate_uid_exist()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	dup_uid_chk()
	{
		x=""
		cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read -r x ; do
			[ -z "$x" ] && return "${XCCDF_RESULT_FAIL:-102}"
			set - "$x"
			if [ "$(echo $x | awk '{print $1}')" -gt 1 ]; then
				echo -e "Users share duplicate UIDs:\n$(awk -v var="$(echo $x | awk '{print $2}')" -F: '($3 == var) {print "user: "$1" ""uid: "$3}' /etc/passwd)" | tee -a "$LOG" 2>> "$ELOG"
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	dup_uid_chk
	if [ "$?" != "102" ]; then
		test=passed
	else
		test=manual
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
			echo "Recommendation \"$RNA\" Another Firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}