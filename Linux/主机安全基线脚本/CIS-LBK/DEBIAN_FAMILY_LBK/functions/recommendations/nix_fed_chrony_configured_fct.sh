#!/usr/bin/env sh
#
# CIS-LBK Cloud Team Built Recommendation Function
# ~/CIS-LBK/functions/fct/nix_fed_chrony_configured_fct.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/21/20    Recommendation "Ensure chrony is configured"
#
fed_chrony_configured_fct()
{
	# Ensure chrony is configured
	echo
	echo \*\*\*\* Ensure\ chrony\ is\ configured
	if rpm -q chrony >/dev/null; then
		egrep -q "^(\s*)OPTIONS\s*=\s*\"(([^\"]+)?-u\s[^[:space:]\"]+([^\"]+)?|([^\"]+))\"(\s*#.*)?\s*$" /etc/sysconfig/chronyd && sed -ri '/^(\s*)OPTIONS\s*=\s*\"([^\"]*)\"(\s*#.*)?\s*$/ {/^(\s*)OPTIONS\s*=\s*\"[^\"]*-u\s+\S+[^\"]*\"(\s*#.*)?\s*$/! s/^(\s*)OPTIONS\s*=\s*\"([^\"]*)\"(\s*#.*)?\s*$/\1OPTIONS=\"\2 -u chrony\"\3/ }' /etc/sysconfig/chronyd && sed -ri "s/^(\s*)OPTIONS\s*=\s*\"([^\"]+\s+)?-u\s[^[:space:]\"]+(\s+[^\"]+)?\"(\s*#.*)?\s*$/\1OPTIONS=\"\2\-u chrony\3\"\4/" /etc/sysconfig/chronyd || echo "OPTIONS=\"-u chrony\"" >> /etc/sysconfig/chronyd
		echo Ensure chrony is configured - server not configured.
	fi

	return "${XCCDF_RESULT_PASS:-201}" 
}