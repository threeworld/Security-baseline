#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_users_dot_netrc_files_not_group_world_accessible.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/09/20    Recommendation "Ensure users' .netrc Files are not group or world accessible"
# 
ensure_users_dot_netrc_files_not_group_world_accessible()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	output="" user="" dir=""
	for i in $(awk -F: '($1!~/(root|halt|sync|shutdown)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
		user=$(echo "$i" | cut -d: -f1)
		dir=$(echo "$i" | cut -d: -f2)
		if [ ! -d "$dir" ]; then
			[ -z "$output" ] && output="The following users' home directories don't exist: \"$user\"" || output="$output, \"$user\""
		else
			file="$dir/.netrc"
			if [ ! -h "$file" ] && [ -f "$file" ]; then
				if stat -L -c "%A" "$file" | cut -c4-10 |  grep -E '[^-]+'; then
					[ -z "$output2" ] && output2="User: \"$user\" file: \"$file\" has permissions: \"$(stat -L -c "%a" "$file")\"" || output2="$output2; User: \"$user\" file: \"$file\" has permissions: \"$(stat -L -c "%a" "$file")\""
				fi
			fi
		fi
	done
	if [ -z "$output2" ]; then
		test=passed
	else
		echo "- $output2" | tee -a "$LOG" 2>> "$ELOG"
		echo "- Making global modifications to users' files without alerting the user community can result in unexpected outages and unhappy users. Therefore, it is recommended that a monitoring policy be established to report user .netrc files and determine the action to be taken in accordance with site policy. -" | tee -a "$LOG" 2>> "$ELOG"
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