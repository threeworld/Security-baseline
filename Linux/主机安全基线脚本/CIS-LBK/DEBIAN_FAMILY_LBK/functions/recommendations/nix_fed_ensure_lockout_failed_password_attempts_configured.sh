#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_lockout_failed_password_attempts_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/06/20    Recommendation "Ensure lockout for failed password attempts is configured"
#

fed_ensure_lockout_failed_password_attempts_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	# If pam_failock.so is used
	pam_failock_function()
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
			if [ "$t0" = passed ] && [ "$t1" = passed ] && [ "$t2" = passed ]  && [ "$t3" = passed ] && [ "$t4" = passed ] && [ "$t5" = passed ]; then
				return "${XCCDF_RESULT_PASS:-101}"
			else
				return "${XCCDF_RESULT_PASS:-103}"
			fi
		else
			return "${XCCDF_RESULT_FAIL:-102}"
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
			if [ "$t1" = passed ] && [ "$t2" = passed ]  && [ "$t3" = passed ] && [ "$t4" = passed ]; then
				return "${XCCDF_RESULT_PASS:-101}"
			else
				return "${XCCDF_RESULT_PASS:-103}"
			fi
		else
			return "${XCCDF_RESULT_FAIL:-102}"
		fi
	}
	# Check if pam_failock or pam_tally is used and call function
	if grep -Eq '^\s*auth\s+required\s+pam_tally2.so\b' /etc/pam.d/system-auth && grep -Eq '^\s*auth\s+required\s+pam_tally2.so\b' /etc/pam.d/password-auth && grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/system-auth && grep -Eq '^\s*account\s+required\s+pam_tally2.so\s*' /etc/pam.d/password-auth; then
		pam_tally2_function
		case "$?" in
			101)
				test=passed
				;;
			103)
				test=remediated
				;;
			*)
				test=""
				;;
		esac
	else
		pam_failock_function
		case "$?" in
			101)
				test=passed
				;;
			103)
				test=remediated
				;;
			*)
				test=""
				;;
		esac
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
			echo "Recommendation \"$RNA\" Something went wrong - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}