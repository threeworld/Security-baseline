#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_core_dumps_restricted.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/16/20    Recommendation "Ensure core dumps are restricted"
# 
core_dumps_restricted()
{
	test=""
	test1=""
	test2=""
	test3=""
	# Test security limits
	if grep -Eqs '^\s*\*\s+hard\s+core\s+0\b' /etc/security/limits.conf /etc/security/limits.d/*; then
		test1=passed
	else
		grep -Eq 'hard\s+core' /etc/security/limits.conf && sed -ri 's/^\s*(\S+)(\s+)(hard\s+core)(\s+)(\S+)(\s+.*)?$/*\2\3\40 \6/' /etc/security/limits.conf
		for file in /etc/security/limits.d/*; do
			grep -Eq 'hard\s+core' "$file" && sed -ri 's/^\s*(\S+)(\s+)(hard\s+core)(\s+)(\S+)(\s+.*)?$/*\2\3\40 \6/' "$file"
		done
		grep -Eqs '^\s*\*\s+hard\s+core\s+0\b' /etc/security/limits.conf /etc/security/limits.d/* || echo "*     hard     core     0" >> /etc/security/limits.d/cis_limits.conf
		grep -Eqs '^\s*\*\s+hard\s+core\s+0\b' /etc/security/limits.conf /etc/security/limits.d/* && test1=remediated
	fi
	# Test sysctl
	if grep -Eqs '^\s*fs.suid_dumpable\s+=\s+0\b' /etc/sysctl.conf /etc/sysctl.d/*; then
		test2=passed
	else
		grep -q 'fs.suid_dumpable' /etc/sysctl.conf && sed -ri 's/^(.*)(fs.suid_dumpable\s+=\s+)(\S+\s*)(\s+#.*)?$/fs.suid_dumpable = 0\4/' /etc/sysctl.conf
		for file in /etc/sysctl.d/*; do
			grep -q 'fs.suid_dumpable' "$file" && sed -ri 's/^(.*)(fs.suid_dumpable\s+=\s+)(\S+\s*)(\s+#.*)?$/fs.suid_dumpable = 0\4/' "$file"
		done
		grep -Eqs '^\s*\fs.suid_dumpable\s*=\s*0\b' /etc/sysctl.conf /etc/sysctl.d/* || echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/cis_sysctl.conf
		sysctl -w fs.suid_dumpable=0
		grep -Eqs '^\s*fs.suid_dumpable\s+=\s+0\b' /etc/sysctl.conf /etc/sysctl.d/* && test2=remediated
	fi
	# Test If systemd-coredump is installed
	if [ -z "$(systemctl is-enabled coredump.service 2>>/dev/null)" ]; then
		test3=passed
	elif grep -Eqs '[Ss]torage\s*=\s*none\b' && grep -Eqs '[Pp]rocess[Ss]ize[Mm]ax\s*=\s*0\b'; then
		test3=passed
	else
		grep -Eqs '[Ss]torage' /etc/systemd/coredump.conf && sed -ri 's/^(.*)([Ss]torage\s*=\s*\S+\s*)(\s+#.*)?$/Storage=none\3/' /etc/systemd/coredump.conf || echo "Storage=none" >> /etc/systemd/coredump.conf
		grep -Eqs '[Pp]rocess[Ss]ize[Mm]ax' /etc/systemd/coredump.conf && sed -ri 's/^(.*)([Pp]rocess[Ss]ize[Mm]ax\s*=\s*\S+\s*)(\s+#.*)?$/ProcessSizeMax=0\3/' /etc/systemd/coredump.conf || echo "ProcessSizeMax=0" >> /etc/systemd/coredump.conf
		if grep -Eqs '[Ss]torage\s*=\s*none\b' && grep -Eqs '[Pp]rocess[Ss]ize[Mm]ax\s*=\s*0\b'; then
			systemctl daemon-reload
			test3=remediated
		fi
	fi
	if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
		if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
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