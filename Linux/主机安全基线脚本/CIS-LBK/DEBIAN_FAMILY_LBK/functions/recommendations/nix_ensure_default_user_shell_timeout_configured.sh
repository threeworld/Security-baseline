#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_ensure_default_user_shell_timeout_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/29/20    Recommendation "Ensure default user shell timeout is configured"
# 
ensure_default_user_shell_timeout_configured()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	test="" test1="" test2=""
	#Set the location of bashrc
	[ -f /etc/bashrc ] && BRC="/etc/bashrc"
	[ -f /etc/bash.bashrc ] && BRC="/etc/bash.bashrc"

	# Check if TMOUT already set correctly
	for file in "$BRC" /etc/profile /etc/profile.d/*.sh ; do 
		if grep -Eq '(^|^[^#]+;)\s*(readonly|export(\s+[^$#;]+\s*)*)?\s*TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$file" && grep -Eq '(^|^[^#]*;)\s*readonly\s+TMOUT\b' "$file" && grep -Eq '(^|^[^#]*;)\s*export\s+([^$#;]+\s+)*TMOUT\b' "$file"; then
			[ -z "$test1" ] && test1=passed
		else
			grep -Eiq 'TMOUT=\S+\b' "$file" && sed -ri 's/^([^#]+\s+)?(TMOUT=\S+)(.*)$/\1\3/' "$file"
			grep -Eiq 'readonly TMOUT=\S+\b' "$file" && sed -ri 's/^([^#]+\s+)?(readonly TMOUT=\S+)(.*)$/\1\3/' "$file"
			sed -ri 's/^\s*export\s+TMOUT\s*(#.*)?$//' "$file"
			grep -Eiq '^(\s*export([^#]+)?(\s*TMOUT=\S+)(.*)$/\1\3/' "$file"
			sed -re 's/^\s*;\s*$//' "$file"
			test1=remediated
		fi
	done

	# Check if TMOUT is set to a longer time
	for file in "$BRC" /etc/profile /etc/profile.d/*.sh ; do 
		if ! grep -Pi '^\s*([^$#;]+\s+)*TMOUT=(9[0-9][1-9]|0+|[1-9]\d{3,})\b\s*(\S+\s*)*(\s+#.*)?$' "$file"; then
			[ -z "$test2" ] && test2=passed
		else
			grep -Eiq 'TMOUT=\S+\b' "$file" && sed -ri 's/^([^#]+\s+)?(TMOUT=\S+)(.*)$/\1\3/' "$file"
			grep -Eiq 'readonly TMOUT=\S+\b' && sed -ri 's/^([^#]+\s+)?(readonly TMOUT=\S+)(.*)$/\1\3/' "$file"
			sed -ri 's/^\s*export\s+TMOUT\s*(#.*)?$//' "$file"
			grep -Eiq '^(\s*export([^#]+)?(\s*TMOUT=\S+)(.*)$/\1\3/' "$file"
			sed -re 's/^\s*;\s*$//' "$file"
			test2=remediated
		fi
	done

	if [ "$test1" = passed ] && [ "$test2" = passed ]; then
		test=passed
	else
		if [ "$test1" != passed ]; then
			test1=""
			"$BRC" /etc/profile /etc/profile.d/*.sh
			if grep -Eq '(^|^[^#]+;)\s*(readonly|export(\s+[^$#;]+\s*)*)?\s*TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$BRC" /etc/profile /etc/profile.d/*.sh && grep -Eq '(^|^[^#]*;)\s*readonly\s+TMOUT\b' "$BRC" /etc/profile /etc/profile.d/*.sh && grep -Eq '(^|^[^#]*;)\s*export\s+([^$#;]+\s+)*TMOUT\b' "$BRC" /etc/profile /etc/profile.d/*.sh; then
				test1=remediated
			else
				echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile.d/cis_profile.sh
				grep -Eq '(^|^[^#]+;)\s*(readonly|export(\s+[^$#;]+\s*)*)?\s*TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$BRC" /etc/profile /etc/profile.d/*.sh && grep -Eq '(^|^[^#]*;)\s*readonly\s+TMOUT\b' "$BRC" /etc/profile /etc/profile.d/*.sh && grep -Eq '(^|^[^#]*;)\s*export\s+([^$#;]+\s+)*TMOUT\b' "$BRC" /etc/profile /etc/profile.d/*.sh && test1=remediated
			fi		
		fi
		if [ "$test2" != passed ]; then
			test2=""
			! grep -Piq '^\s*([^$#;]+\s+)*TMOUT=(9[0-9][1-9]|0+|[1-9]\d{3,})\b\s*(\S+\s*)*(\s+#.*)?$' /etc/profile /etc/profile.d/*.sh /etc/bashrc && test2=remediated
		fi
		if [ -n "$test1" ] && [ -n "$test2" ]; then
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