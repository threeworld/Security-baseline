#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_sudo_commands_pty.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/14/20    Recommendation "Ensure sudo commands use pty"
# 
ensure_sudo_commands_pty()
{
	test=""
	if grep -Eisq '^\s*Defaults\s+([^#]+,\s*)?use_pty' /etc/sudoers /etc/sudoers.d/*; then
		test=passed
	else
		for file in /etc/sudoers /etc/sudoers.d/*; do
			if grep -Esq '^(\s*Defaults\s+(?:[^#]+(?:,|\s+))?)(!use_pty)((,|\s+).*)?$' "$file"; then
				sed -ri 's/^(\s*Defaults\s+([^#]+(,|\s+))?)(!use_pty)((,|\s+).*)?$/\1use_pty\5/' "$file"
			fi
		done
		! grep -Eisq '^\s*Defaults\s+([^#]+,\s*)?use_pty' /etc/sudoers /etc/sudoers.d/* && echo "Defaults use_pty" >> /etc/sudoers.d/cis_sudoers.conf
		grep -Eisq '^\s*Defaults\s+([^#]+,\s*)?use_pty' /etc/sudoers /etc/sudoers.d/* && test=remediated
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