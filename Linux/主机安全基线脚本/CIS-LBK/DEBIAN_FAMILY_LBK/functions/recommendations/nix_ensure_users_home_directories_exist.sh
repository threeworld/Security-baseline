#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_users_home_directories_exist.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/09/20    Recommendation "Ensure all users' home directories exist"
# 
ensure_users_home_directories_exist()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	output="" user="" dir=""
	for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
		user=$(echo "$i" | cut -d: -f1)
		dir=$(echo "$i" | cut -d: -f2)
		if [ ! -d "$dir" ]; then
			[ -z "$output" ] && output="User \"$user\" missing home directory \"$dir\"" || output="$output; User \"$user\" missing home directory \"$dir\""
		fi
	done
	if [ -z "$output" ]; then
		test=passed
	else
		[ -n "$output" ] && echo "$output" | tee -a "$LOG" 2>> "$ELOG"
    	echo "- $(date +%d-%b-%Y' '%T) - remediating $RNA" | tee -a "$LOG" 2>> "$ELOG"
		for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
			user=$(echo "$i" | cut -d: -f1)
			dir=$(echo "$i" | cut -d: -f2)
			if [ ! -d "$dir" ]; then
				echo "User: \"$user\" home directory: \"$dir\" does not exist, creating home directory" | tee -a "$LOG" 2>> "$ELOG"
				mkdir "$dir"
				chmod g-w,o-rwx "$dir"
				chown "$user" "$dir"
				[ -d "$dir" ] && echo "User: \"$user\" home directory: \"$dir\" created successfully" | tee -a "$LOG" 2>> "$ELOG"
			fi
		done
	    # Check if remediation was successful
	    echo "- $(date +%d-%b-%Y' '%T) - verifying $RNA remediated successfully" | tee -a "$LOG" 2>> "$ELOG"
	    output=""
		for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
			user=$(echo "$i" | cut -d: -f1)
			dir=$(echo "$i" | cut -d: -f2)
			if [ ! -d "$dir" ]; then
				[ -z "$output" ] && output="User \"$user\" missing home directory \"$dir\"" || output="$output; User \"$user\" missing home directory \"$dir\""
			fi
		done
		if [ -z "$output" ]; then
			test=remediated
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
			echo "Recommendation \"$RNA\" Another Firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}