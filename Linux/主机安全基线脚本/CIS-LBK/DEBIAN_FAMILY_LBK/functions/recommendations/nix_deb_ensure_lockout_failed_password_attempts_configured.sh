#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_lockout_failed_password_attempts_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/23/20    Recommendation "Ensure lockout for failed password attempts is configured"
#

deb_ensure_lockout_failed_password_attempts_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test=""
	
	t1="" t2="" t3=""
	# Check /etc/pam.d/common-auth file
	if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-auth | grep -Eq 'deny=[1-5]'; then
		t1=passed
	else
		if grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-auth | grep -Eq 'deny='; then
			sed -ri 's/s/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s+)?(deny=\S=\s+)(.*)$/\1\3 deny=5 \5/' /etc/pam.d/common-auth
		elif grep -Eq '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-auth; then
			sed -ri 's/^\s*(auth\s+(required|requisite)\s+pam_tally2.so\s+)([^#]+\s*)?(.*)?$/\1\3 deny=5 \4/' /etc/pam.d/common-auth
		else
			if grep -Eq '^\s*#\s+end\s+of\s+pam-auth-update\s+config' /etc/pam.d/common-auth; then
				sed -ri '/^\s*#\s+end\s+of\s+pam-auth-update\s+config/i auth        required      pam_tally2.so preauth silent audit deny=5 unlock_time=900' /etc/pam.d/common-auth
			else
				echo "auth        required      pam_tally2.so preauth silent audit deny=5 unlock_time=900" /etc/pam.d/common-auth
			fi
		fi
		grep -E '^\s*auth\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-auth | grep -Eq 'deny=[1-5]' && t1=remediated
	fi

	# Check /etc/pam.d/common-account file
	if grep -E '^\s*account\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-account; then
		t2=passed
	else
		if grep -Eq '^\s*#\s+end\s+of\s+pam-auth-update\s+config' /etc/pam.d/common-account; then
			sed -ri '/^\s*#\s+end\s+of\s+pam-auth-update\s+config/i account required                        pam_tally2.so' /etc/pam.d/common-account
		else
			echo "account required                        pam_tally2.so" /etc/pam.d/common-account
		fi
		grep -E '^\s*account\s+(required|requisite)\s+pam_tally2.so\b' /etc/pam.d/common-account && t2=remediated
	fi

	if grep -E '^\s*account\s+(required|requisite)\s+pam_deny.so\b' /etc/pam.d/common-account; then
		t3=passed
	else
		if grep -Eq '^\s*#\s+end\s+of\s+pam-auth-update\s+config'; then
			sed -ri '/^\s*#\s+end\s+of\s+pam-auth-update\s+config/i account requisite                       pam_deny.so' /etc/pam.d/common-account
		else
			echo "account requisite                       pam_deny.so" /etc/pam.d/common-account
		fi
		grep -E '^\s*account\s+(required|requisite)\s+pam_deny.so\b' /etc/pam.d/common-account && t3=remediated
	fi

	if [ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ]; then
		if [ "$t1" = passed ] && [ "$t2" = passed ]  && [ "$t3" = passed ]; then
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