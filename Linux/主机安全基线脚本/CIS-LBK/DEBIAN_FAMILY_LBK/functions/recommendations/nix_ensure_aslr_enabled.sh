#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_aslr_enabled.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/16/20    Recommendation "Ensure address space layout randomization (ASLR) is enabled"
# 
ensure_aslr_enabled()
{
	test=""
	# Test security limits
	if sysctl kernel.randomize_va_space | grep -E 'kernel\.randomize_va_space\s*=\s*2\b' && grep -Eqs '^\s*kernel\.randomize_va_space\s*=\s*2\b' /etc/sysctl.conf /etc/sysctl.d/*; then
		test=passed
	else
		if grep -Eqs '^\s*kernel.randomize_va_space\s*=\s*2\b' /etc/sysctl.conf /etc/sysctl.d/*; then
			sysctl -w kernel.randomize_va_space=2
		else
			grep -q 'kernel.randomize_va_space' /etc/sysctl.conf && sed -ri 's/^(.*)(kernel\.randomize_va_space\s*=\s*\S+\s*)(\s+#.*)?$/kernel.randomize_va_space = 2\3' /etc/sysctl.conf
			for file in /etc/sysctl.d/*; do
				grep -qs 'kernel.randomize_va_space' "$file" && sed -ri 's/^(.*)(kernel\.randomize_va_space\s*=\s*\S+\s*)(\s+#.*)?$/kernel.randomize_va_space = 2\3' "$file"
			done
			if ! grep -Eqs '^\s*kernel.randomize_va_space\s*=\s*2\b' /etc/sysctl.conf /etc/sysctl.d/*; then
				echo "kernel.randomize_va_space = 2" >> /etc/sysctl.d/cis_sysctl.conf
			fi
			sysctl -w kernel.randomize_va_space=2
		fi
		if sysctl kernel.randomize_va_space | grep -E 'kernel\.randomize_va_space\s*=\s*2\b' && grep -Eqs '^\s*kernel\.randomize_va_space\s*=\s*2\b' /etc/sysctl.conf /etc/sysctl.d/*; then
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