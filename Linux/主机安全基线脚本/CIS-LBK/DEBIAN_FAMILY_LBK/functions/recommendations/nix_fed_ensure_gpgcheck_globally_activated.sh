#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_gpgcheck_globally_activated.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure gpgcheck is globally activated"
# 
fed_ensure_gpgcheck_globally_activated()
{
	test=""
	grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf && test1=passed
	[ -z "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ] && test2=passed
	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		if ! grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf; then
			if grep -Eq '^\s*gpgcheck\s*=' /etc/yum.conf; then
				sed -ri 's/(^\s*gpgcheck\s*)(\s*=\S+)(\s+#.*)?$/\1=1\3/' /etc/yum.conf
			else
				sed '/[main]/a gpgcheck=1' /etc/yum.conf
			fi
			grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf && test1=remediated
		fi
		if [ -n "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ]; then
			for file in grep -Es '^\s*gpgcheck\s*=\s*[^1]\s*(\s+#.*)?$' /etc/yum.repos.d/* ; do
				sed -ri 's/(^\s*gpgcheck\s*)(\s*=\S+)(\s+#.*)?$/\1=1\3/' "$file"
			done
			[ -z "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ] && test2=remediated
		fi
	fi
	[ "$test" != passed ] && [ -n "$test1" ] && [ -n "$test2" ] && test=remediated 	


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