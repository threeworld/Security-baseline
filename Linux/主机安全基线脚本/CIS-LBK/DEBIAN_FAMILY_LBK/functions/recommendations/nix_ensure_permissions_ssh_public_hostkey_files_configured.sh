#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_permissions_ssh_public_hostkey_files_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/22/20    Recommendation "Ensure permissions on SSH public host key files are configured"
# 
ensure_permissions_ssh_public_hostkey_files_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	ssh_phkf_chk1()
	{
		file=""
		find -L /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' | while read -r file; do
			if ! stat -Lc "%A" "$file" | grep -Eq -- "-[r-][w-]-[r-]--[r-]--"; then
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	ssh_phkf_chk2()
	{
		file=""
		find -L /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' | while read -r file; do
			if [ "$(stat -Lc "%U %G" "$file")" != "root root" ]; then
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		done
	}
	ssh_phkf_fix1()
	{
		file=""
		find -L /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' | while read -r file; do
			if ! stat -Lc "%A" "$file" | grep -Eq -- "-[r-][w-]-[r-]--[r-]--"; then
				chmod u-x,go-wx "$file"
			fi
		done		
	}
	ssh_phkf_fix2()
	{
		file=""
		find -L /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' | while read -r file; do
			if [ "$(stat -Lc "%U %G" "$file")" != "root root" ]; then
				chown root:root "$file"
			fi
		done	
	}

	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check is openssh-server is installed
	if ! $PQ openssh-server >/dev/null; then
		test=NA
	else
		if [ -n "$(find -L /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub')" ]; then
			ssh_phkf_chk1
			if [ "$?" != "102" ]; then
				test1=passed
			else
				ssh_phkf_fix1
				if [ "$?" != "102" ]; then
				 test1=remediated
				fi
			fi
			ssh_phkf_chk2
			if [ "$?" != "102" ]; then
				test2=passed
			else
				ssh_phkf_fix2
				if [ "$?" != "102" ]; then
				 test2=remediated
				fi
			fi
			if [ -n "$test1" ] && [ -n "$test2" ]; then
				if [ "$test1" = passed ] && [ "$test2" = passed ]; then
					test=passed
				else
					test=remediated
				fi
			fi
		else
			test=passed
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
		NA)
			echo "Recommendation \"$RNA\" openssh-server not installed - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}