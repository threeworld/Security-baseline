#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_authentication_singleuser_mode.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/16/20    Recommendation "Ensure authentication required for single user mode"
# 
fed28_authentication_singleuser_mode()
{
	test=""
	test1=""
	test2=""
	# Test rescue.service
	if grep -Eq '^\s*ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s+rescue' /usr/lib/systemd/system/rescue.service; then
		test1=passed
	else
		if grep -Eq '^\s*ExecStart=' /usr/lib/systemd/system/rescue.service; then
			sed -ri 's/(^\s*ExecStart=.*)$/# \1/' /usr/lib/systemd/system/rescue.service
			sed -ri '/^\s*#\s+ExecStart=.*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue' /usr/lib/systemd/system/rescue.service
		else
			if grep -Eq '^\s*#\s*ExecStart=' /usr/lib/systemd/system/rescue.service; then
				sed -ri '/^\s*#\s+ExecStart=.*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue' /usr/lib/systemd/system/rescue.service
			else
				sed -ri '/[Service].*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue' /usr/lib/systemd/system/rescue.service
			fi
		fi
		grep -Eq '^\s*ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s+rescue' /usr/lib/systemd/system/rescue.service && test1=remediated
	fi
	# Test emergency.service
	if grep -Eq '^\s*ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s+emergency' /usr/lib/systemd/system/emergency.service; then
		test2=passed
	else
		if grep -Eq '^\s*ExecStart=' /usr/lib/systemd/system/emergency.service; then
			sed -ri 's/(^\s*ExecStart=.*)$/# \1/' /usr/lib/systemd/system/emergency.service
			sed -ri '/^\s*#\s+ExecStart=.*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency' /usr/lib/systemd/system/emergency.service
		else
			if grep -Eq '^\s*#\s*ExecStart=' /usr/lib/systemd/system/emergency.service; then
				sed -ri '/^\s*#\s+ExecStart=.*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency' /usr/lib/systemd/system/emergency.service
			else
				sed -ri '/[Service].*/a ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency' /usr/lib/systemd/system/emergency.service
			fi
		fi
		grep -Eq '^\s*ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s+emergency' /usr/lib/systemd/system/emergency.service && test2=remediated
	fi                                                   
	if [ -n "$test1" ] && [ -n "$test2" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi
	# Set return code and return
	if [ "$test" = passed ]; then
		echo "Recommendation \"$RNA\" No remediation required" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	elif [ "$test" = remediated ]; then
		echo "Recommendation \"$RNA\" successfully remediated" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-103}" 
	else
		echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}