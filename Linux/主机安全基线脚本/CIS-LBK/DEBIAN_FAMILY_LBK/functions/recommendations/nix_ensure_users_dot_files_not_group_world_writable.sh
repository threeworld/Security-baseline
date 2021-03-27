#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_users_dot_files_not_group_world_writable.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/09/20    Recommendation "Ensure users' dot files are not group or world writable"
# 
ensure_users_dot_files_not_group_world_writable()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	output="" output2="" user="" dir=""
	for i in $(awk -F: '($1!~/(halt|sync|shutdown)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
		user=$(echo "$i" | cut -d: -f1)
		dir=$(echo "$i" | cut -d: -f2)
		if [ ! -d "$dir" ]; then
			[ -z "$output" ] && output="The following users' home directories don't exist: \"$user\"" || output="$output, \"$user\""
		else
			for file in "$dir"/.*; do
				if [ ! -h "$file" ] && [ -f "$file" ]; then
					fileperm=$(stat -L -c "%A" "$file")
					if [ "$(echo "$fileperm" | cut -c6)" != "-" ] || [ "$(echo "$fileperm" | cut -c9)" != "-" ]; then
						[ -z "$output2" ] && output2="User: \"$user\" file: \"$file\" has permissions: \"$(stat -L -c "%a" "$file")\"" || output2="$output2; User: \"$user\" file: \"$file\" has permissions: \"$(stat -L -c "%a" "$file")\""
					fi
				fi
			done
		fi
	done
	if [ -z "$output2" ]; then
		test=passed
	else
		[ -n "$output2" ] && echo "$output2" | tee -a "$LOG" 2>> "$ELOG"
    	[ -n "$output" ] && echo "WARNING: $output" | tee -a "$LOG" 2>> "$ELOG"
    	test=manual
    	# Making global modifications to users' files without alerting the user community can result in unexpected outages and unhappy users. 
    	# Therefore, it is recommended that a monitoring policy be established to report user dot file permissions and determine the action
    	# to be taken in accordance with site policy.
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