#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_users_own_their_home_directories.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/09/20    Recommendation "Ensure users own their home directories"
# 
ensure_users_own_their_home_directories()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""	output="" output2="" user="" dir=""
	for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
		user=$(echo "$i" | cut -d: -f1)
		dir=$(echo "$i" | cut -d: -f2)
		if [ -d "$dir" ]; then
			owner="$(stat -L -c "%U" "$dir")"
			if [ "$owner" != "$user" ]; then
				[ -z "$output" ] && output="The following users don't own their home directory: $user" || output=", $user"
			fi
		fi
	done
	if [ -z "$output" ]; then
		test=passed
	else
		# Perform remediation
		user="" dir=""
		awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1" "$6}' /etc/passwd | while read -r user dir; do
			if [ ! -d "$dir" ]; then
				mkdir "$dir"
				chmod g-w,o-rwx "$dir"
				chown "$user" "$dir"
			else
				owner="$(stat -L -c "%U" "$dir")"
				if [ "$owner" != "$user" ]; then
#					chmod g-w,o-rwx "$dir"
					chown "$user" "$dir"
				fi
			fi
		done
#		output="" output2="" user="" dir=""
#		for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
#			user=$(echo "$i" | cut -d: -f1)
#			dir=$(echo "$i" | cut -d: -f2)
#			if [ ! -d "$dir" ]; then
#				mkdir $dir
#				chmod g-w,o-rwx "$dir"
#				chown "$user" "$dir"
#			else
#				owner="$(stat -L -c "%U" "$dir")"
#				if [ "$owner" != "$user" ]; then
#					chmod g-w,o-rwx "$dir"
#					chown "$user" "$dir"
#				fi
#			fi
#		done
		# Check if remediation was successful
		output="" output2="" user="" dir=""
		for i in $(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd); do
			user=$(echo "$i" | cut -d: -f1)
			dir=$(echo "$i" | cut -d: -f2)
			if [ ! -d "$dir" ]; then
				[ -z "$output2" ] && output2="The following user's home directories are missing: $user" || output2=", $user"
			else
				owner="$(stat -L -c "%U" "$dir")"
				if [ "$owner" != "$user" ]; then
					[ -z "$output" ] && output="The following users don't own their home directory: $user" || output=", $user"
				fi
			fi
		done
		if [ -z "$output" ]; then
			test=remediated
			[ -n "$output2" ] && echo "$output2" | tee -a "$LOG" 2>> "$ELOG"
		else
			[ -n "$output2" ] && echo "$output2" | tee -a "$LOG" 2>> "$ELOG"
			[ -n "$output" ] && echo "$output" | tee -a "$LOG" 2>> "$ELOG"
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