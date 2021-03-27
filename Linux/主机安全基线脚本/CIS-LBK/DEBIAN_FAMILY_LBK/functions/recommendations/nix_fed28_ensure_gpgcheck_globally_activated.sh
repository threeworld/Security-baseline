#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed28_ensure_gpgcheck_globally_activated.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/11/20    Recommendation "Ensure gpgcheck is globally activated"
# Eric Pinnell       10/20/20    Modified to account for an "error" in the current assessment for CIS-CAT.  This will allow the check to pass the "too restrictive" check in CIS-CAT.  This should be replaced with the non fed28 version as soon as the Assessment is corrected
# 
fed28_ensure_gpgcheck_globally_activated()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	# Check yum.conf
	if grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf; then
		test1=passed
	else
		if grep -Eq 's/^\s*(#\s*)?gpgcheck=' /etc/yum.conf; then
			sed -ri 's/^\s*(#\s*)?(gpgcheck=)(\S+)(.*)?$/\21/' /etc/yum.conf
		else
			grep -q '\[main\]' /etc/yum.conf &&  sed -i '/\[main\]/a gpgcheck=1' /etc/yum.conf || echo "gpgcheck=1" /etc/yum.conf
		fi
		grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf && test1=remediated
	fi
	# Test .repo files in the /etc/yum.repos.d/ directory
	for file in /etc/yum.repos.d/*.repo; do
		[ -e "$file" ] || break
		if ! grep -Eq '^\s*gpgcheck\s*=\s*[^1]\b' "$file"; then
			[ -z "$test2" ] && test2=passed
		else
			echo "- $(date +%d-%b-%Y' '%T) - remediating $file" | tee -a "$LOG" 2>> "$ELOG"
			sed -ri 's/^\s*(gpgcheck=)(\S+)(.*)?$/\11/' "$file"
			if ! grep -Eq '^\s*gpgcheck\s*=\s*[^1]\b' "$file"; then
				[ "$test2" != failed ] && test2=remediated
			else
				test2=failed
			fi
		fi
	done
	# Check for test state
	if [ -n "$test1" ] && [ -n "$test2" ] && [ "$test2" != failed ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ]; then
			test=passed
		else
			test=remediated
		fi
	fi

# This will not allow the "too restrictive" test in the current assessment to pass
#	[ -z "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ] && test2=passed
#	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
#		test=passed
#	else
#		if ! grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf; then
#			if grep -Eq '^\s*gpgcheck\s*=' /etc/yum.conf; then
#				sed -ri 's/(^\s*gpgcheck\s*)(\s*=\S+)(\s+#.*)?$/\1=1\3/' /etc/yum.conf
#			else
#				sed '/[main]/a gpgcheck=1' /etc/yum.conf
#			fi
#			grep -Eq '^\s*gpgcheck\s*=\s*1\b' /etc/yum.conf && test1=remediated
#		fi
#		if [ -n "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ]; then
#			for file in grep -Es '^\s*gpgcheck\s*=\s*[^1]\s*(\s+#.*)?$' /etc/yum.repos.d/* ; do
#				sed -ri 's/(^\s*gpgcheck\s*)(\s*=\S+)(\s+#.*)?$/\1=1\3/' "$file"
#			done
#			[ -z "$(awk -v 'RS=[' -F '\n' '/\n\s*enabled\s*=\s*1(\W.*)?$/ && ! /\n\s*gpgcheck\s*=\s*1(\W.*)?$/ { t=substr($1, 1, index($1, "]")-1); print t, "not enabled." }' /etc/yum.repos.d/*.repo)" ] && test2=remediated
#		fi
#	fi
#	[ "$test" != passed ] && [ -n "$test1" ] && [ -n "$test2" ] && test=remediated 	


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