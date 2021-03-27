#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed19_ensure_login_logout_events_collected.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/10/20    Recommendation "Ensure login and logout events are collected"
# 
fed19_ensure_login_logout_events_collected()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2="" test3=""

	# Sub function to setup account lockout methiod if no methiod is configured on the system
	config_lockout_methiod()
	{
		echo "- $(date +%d-%b-%Y' '%T) - Starting setup account lockout methiod" | tee -a "$LOG" 2>> "$ELOG"
		test=""
		# If pam_faillock.so is used
		pam_faillock_function()
		{
			t0="" t1="" t2="" t3="" t4="" file=""
			# Check /etc/pam.d/system-auth auth section
			file="/etc/pam.d/system-auth"
			# Check preauth
			if grep -Pq '^\s*auth\s+(?:required|requisite)\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(preauth|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(preauth|deny=[1-5])\b' "$file"; then
				t0=passed
			else
				if grep -E '^\s*auth\s+(required|requisite)\s+pam_faillock.so\s+([^#]+)?preauth\b' "$file" | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+(required|requisite)\s+pam_faillock.so\s+)([^#]+\s+)?(deny=\S+\s+)(.*)$/\1\3 deny=5 \5/' "$file"
				elif grep -Eq '^\s*auth\s+(required|requisite)\s+pam_faillock.so\s+([^#]+)?preauth\b' "$file"; then
					sed -ri 's/^\s*(auth\s+(required|requisite)\s+pam_faillock.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' "$file"
				else
					sed -ri '/^\s*auth\s+required\s+pam_env.so\b/a auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' "$file"
				fi
				 grep -Pq '^\s*auth\s+(?:required|requisite)\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(preauth|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(preauth|deny=[1-5])\b' "$file" && t0=remediated
			fi
			# Check authfail
			if grep -Pq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(authfail|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(authfail|deny=[1-5])\b' "$file"; then
				t1=passed
			else
				if grep -E '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+([^#]+)?authfail\b' "$file" | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+\[default=die\]\s+pam_faillock.so\s+)([^#]+\s+)?(deny=\S+\s+)(.*)$/\1\3 deny=5 \5/' "$file"
				elif grep -Eq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+([^#]+)?authfail\b' "$file"; then
					sed -ri 's/^\s*(auth\s+\[default=die\]\s+pam_faillock.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' "$file"
				else
					sed -ri '/^\s*auth\s+(required|requisite)\s+pam_succeed_if.so\b/i auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' "$file"
				fi
				 grep -Pq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(authfail|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(authfail|deny=[1-5])\b' "$file" && t1=remediated
			fi
			# Check /etc/pam.d/system-auth account section
			if grep -Eq '^\s*account\s+required\s+pam_faillock.so\s*' "$file"; then
				t2=passed
			else
				sed -ri '/^\s*account\s+required\s+/i account     required     pam_faillock.so' "$file"
			fi
			grep -Eq '^\s*account\s+required\s+pam_faillock.so\s*' "$file" && t2=remediated

			# Check /etc/pam.d/password-auth auth section
			file="/etc/pam.d/password-auth"
			# Check preauth
			if grep -Pq '^\s*auth\s+(?:required|requisite)\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(preauth|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(preauth|deny=[1-5])\b' "$file"; then
				t3=passed
			else
				if grep -E '^\s*auth\s+(required|requisite)\s+pam_faillock.so\s+([^#]+)?preauth\b' "$file" | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+(required|requisite)\s+pam_faillock.so\s+)([^#]+\s+)?(deny=\S+\s+)(.*)$/\1\3 deny=5 \5/' "$file"
				elif grep -Eq '^\s*auth\s+(required|requisite)\s+pam_faillock.so\s+([^#]+)?preauth\b' "$file"; then
					sed -ri 's/^\s*(auth\s+(required|requisite)\s+pam_faillock.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' "$file"
				else
					sed -ri '/^\s*auth\s+required\s+pam_env.so\b/a auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' "$file"
				fi
				 grep -Pq '^\s*auth\s+(?:required|requisite)\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(preauth|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(preauth|deny=[1-5])\b' "$file" && t3=remediated
			fi
			# Check authfail
			if grep -Pq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(authfail|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(authfail|deny=[1-5])\b' "$file"; then
				t4=passed
			else
				if grep -E '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+([^#]+)?authfail\b' "$file" | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+\[default=die\]\s+pam_faillock.so\s+)([^#]+\s+)?(deny=\S+\s+)(.*)$/\1\3 deny=5 \5/' "$file"
				elif grep -Eq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+([^#]+)?authfail\b' "$file"; then
					sed -ri 's/^\s*(auth\s+\[default=die\]\s+pam_faillock.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' "$file"
				else
					sed -ri '/^\s*auth\s+(required|requisite)\s+pam_succeed_if.so\b/i auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' "$file"
				fi
				 grep -Pq '^\s*auth\s+\[default=die\]\s+pam_faillock.so\s+(?:[^#]+\s+)?(?!\2)(authfail|deny=[1-5])\s*(?:[^#]+\s+)?(?!\1)(authfail|deny=[1-5])\b' "$file" && t4=remediated
			fi
			# Check /etc/pam.d/password-auth account section
			if grep -Eq '^\s*account\s+required\s+pam_faillock.so\s*' "$file"; then
				t5=passed
			else
				sed -ri '/^\s*account\s+required\s+/i account     required     pam_faillock.so' "$file"
			fi
			grep -Eq '^\s*account\s+required\s+pam_faillock.so\s*' "$file" && t5=remediated

			if [ -n "$t0" ] && [ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ] && [ -n "$t4" ] && [ -n "$t5" ]; then
				return "${XCCDF_RESULT_PASS:-101}"
			fi
		}
		# If pam_tally2.so is used
		pam_tally2_function()
		{
			t1="" t2="" t3="" t4=""
			# Check /etc/pam.d/system-auth auth section
			if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/system-auth | grep -Eq 'deny=[1-5]'; then
				t1=passed
			else
				if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/system-auth | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s+)?(deny=\S=\s+)(.*)$/\1\3 deny=5 \5/' /etc/pam.d/system-auth
				elif grep -Eq '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/system-auth; then
					sed -ri 's/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' /etc/pam.d/system-auth
				else
					sed -ri '/^\s*auth\s+required\s+pam_env.so\b/a auth        required      pam_tally2.so preauth silent audit deny=5 unlock_time=900' /etc/pam.d/system-auth
				fi
				grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/system-auth | grep -Eq 'deny=[1-5]' && t1=remediated
			fi
			# Check /etc/pam.d/password-auth auth section
			if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/password-auth | grep -Eq 'deny=[1-5]'; then
				t2=passed
			else
				if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/password-auth | grep -Eq 'deny='; then
					sed -ri 's/s/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s+)?(deny=\S=\s+)(.*)$/\1\3 deny=5 \5/' /etc/pam.d/password-auth
				elif grep -Eq '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/password-auth; then
					sed -ri 's/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' /etc/pam.d/password-auth
				else
					sed -ri '/^\s*auth\s+required\s+pam_env.so\b/a auth        required      pam_tally2.so preauth silent audit deny=5 unlock_time=900' /etc/pam.d/password-auth
				fi
				grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/password-auth | grep -Eq 'deny=[1-5]' && t2=remediated
			fi
			# Check /etc/pam.d/system-auth account section
			if grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/system-auth; then
				t3=passed
			else
				sed -ri '/^\s*account\s+required\s+/i account     required     pam_tally2.so' /etc/pam.d/system-auth
			fi
			grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/system-auth && t3=remediated
			# Check /etc/pam.d/password-auth account section
			if grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/password-auth; then
				t4=passed
			else
				sed -ri '/^\s*account\s+required\s+/i account     required     pam_tally2.so' /etc/pam.d/password-auth
			fi
			if [ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ] && [ -n "$t4" ]; then
				return "${XCCDF_RESULT_PASS:-101}"
			fi
		}
		# Check if pam_faillock or pam_tally is used and call function
		if grep -Eq '^\s*auth\s+required\s+pam_tally2.so\b' /etc/pam.d/system-auth && grep -Eq '^\s*auth\s+required\s+pam_tally2.so\b' /etc/pam.d/password-auth && grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/system-auth && grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/password-auth; then
			pam_tally2_function
			frv="$?"
		else
			pam_faillock_function
			frv="$?"
		fi
		if [ "$frv" = 101 ]; then
			return "${XCCDF_RESULT_PASS:-101}"
		fi
	}
	# Subfunction to determine which account lockout methiod is used
	tally_chk()
	{
		# Check which account lockout methiod is used

		# Check if pam_faillock is used
		t1="" t2=""
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_faillock\.so\b' /etc/pam.d/system-auth && grep -Eqs '^\s*account\s+required\s+pam_faillock\.so\b' /etc/pam.d/system-auth && t1=pass
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_faillock\.so\b' /etc/pam.d/password-auth && grep -Eqs '^\s*account\s+required\s+pam_faillock\.so\b' /etc/pam.d/password-auth && t2=pass
		if [ "$t1" = pass ] && [ "$t2" = pass ]; then
			faillock=yes
			echo "pam_faillock is used on the system" | tee -a "$LOG" 2>> "$ELOG"
		fi

		# Check if pam_tally2 is used
		t1="" t2=""
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/system-auth && grep -Eqs '^\s*account\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/system-auth && t1=pass
		grep -Eqs '^\s*auth\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/password-auth && grep -Eqs '^\s*account\s+(required|requisite)\s+pam_tally2\.so\b' /etc/pam.d/password-auth && t2=pass
		if [ "$t1" = pass ] && [ "$t2" = pass ]; then
			tally2=yes
			echo "pam_tally2 is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
		fi
		if [ -n "$faillock" ] || [ -n "$tally2" ]; then
			return "${XCCDF_RESULT_PASS:-101}"
		else
			echo "neither pam_faillock or pam_tally2 configured, calling configuration function" | tee -a "$LOG" 2>> "$ELOG"
			frv=""
			config_lockout_methiod
			if [ "$?" = "101" ] && [ "$tcr" != "yes" ]; then
				tcr=yes
				tally_chk
			else
				return "${XCCDF_RESULT_FAIL:-102}"
			fi
		fi
	}

	# Check rule "-w /var/log/faillog -p wa -k {key name}"
	t1="" t2=""
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/faillog\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
	[ "$t1" = passed ] && [ "$t2" = passed ] && test1=passed

	# Check rule "-w /var/log/lastlog -p wa -k {key name}"
	t1="" t2=""
	XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/lastlog\/?\s+-p\s+wa\s+-k\s+\S+\b"
	# Check running auditd config for rule
	nix_auditd
	[ "$?" = "101" ] && t1=passed
	# Check rules files for rule
	nix_auditd_uid_file_v3
	[ "$?" = "101" ] && t2=passed || echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
	[ "$t1" = passed ] && [ "$t2" = passed ] && test2=passed

	# Check which pam lockout module is in use on the system
	if [ -z "$faillock" ] && [ -z "$tally2" ]; then
		echo "Checking for account lockout methiod" | tee -a "$LOG" 2>> "$ELOG"
		tally_chk
		[ "$?" = "101" ] && echo "Check for account lockout methiod successful" | tee -a "$LOG" 2>> "$ELOG" || echo "Check for account lockout methiod failed" | tee -a "$LOG" 2>> "$ELOG"
	fi
	# Check for either "-w /var/run/faillock/ -p wa -k {key name}" or "-w /var/log/tallylog -p wa -k {key name}"
	if [ "$faillock" = yes ]; then
		 echo "Account lockout methiod is pam_faillock" | tee -a "$LOG" 2>> "$ELOG"
		# check rule "-w /var/run/faillock/ -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/faillock\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule 
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-w /var/run/faillock/ -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	elif [ "$tally2" = yes ]; then
		echo "Account lockout methiod is pam_tally2" | tee -a "$LOG" 2>> "$ELOG"
		# check rule "-w /var/log/tallylog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/tallylog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule 
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed || echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/50-logins.rules
		[ "$t1" = passed ] && [ "$t2" = passed ] && test3=passed
	fi

	# Check results of checks
	if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
		test=passed
	else
		service auditd restart
		sleep 5
		# Check rule "-w /var/log/faillog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/faillog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test1=remediated

		# Check rule "-w /var/log/lastlog -p wa -k {key name}"
		t1="" t2=""
		XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/lastlog\/?\s+-p\s+wa\s+-k\s+\S+\b"
		# Check running auditd config for rule
		nix_auditd
		[ "$?" = "101" ] && t1=passed
		# Check rules files for rule
		nix_auditd_uid_file_v3
		[ "$?" = "101" ] && t2=passed
		[ "$t1" = passed ] && [ "$t2" = passed ] && test2=remediated

		# Check which pam lockout module is in use on the system
		if [ -z "$faillock" ] && [ -z "$tally2" ]; then
			echo "re-running account lockout methiod check..." | tee -a "$LOG" 2>> "$ELOG"
			tally_chk
			[ "$?" = "101" ] && echo "Check for account lockout methiod successful" | tee -a "$LOG" 2>> "$ELOG" || echo "Check for account lockout methiod failed" | tee -a "$LOG" 2>> "$ELOG"
		fi
		# Check for either "-w /var/run/faillock/ -p wa -k {key name}" or "-w /var/log/tallylog -p wa -k {key name}"
		if [ "$faillock" = yes ]; then
			echo "Account lockout methiod is pam_faillock" | tee -a "$LOG" 2>> "$ELOG"
			# check rule "-w /var/run/faillock/ -p wa -k {key name}"
			t1="" t2=""
			XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/run\/faillock\/?\s+-p\s+wa\s+-k\s+\S+\b"
			# Check running auditd config for rule
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule 
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		elif [ "$tally2" = yes ]; then
			echo "Account lockout methiod is pam_tally2" | tee -a "$LOG" 2>> "$ELOG"
			# check rule "-w /var/log/tallylog -p wa -k {key name}"
			t1="" t2=""
			XCCDF_VALUE_REGEX="^\s*-w\s+\/var\/log\/tallylog\/?\s+-p\s+wa\s+-k\s+\S+\b"
			# Check running auditd config for rule
			nix_auditd
			[ "$?" = "101" ] && t1=passed
			# Check rules files for rule 
			nix_auditd_uid_file_v3
			[ "$?" = "101" ] && t2=passed
			[ "$t1" = passed ] && [ "$t2" = passed ] && test3=remediated
		fi
	fi
	# Check to see test status
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
			test=passed
		else
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
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}