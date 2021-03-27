#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_gdm_login_banner_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       09/30/20    Recommendation "Ensure GDM login banner is configured"
# 
fed_ensure_gdm_login_banner_configured()
{
	test=""
	# Set package manager information
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check if setroubleshoot is not installed
	if ! $PQ gdm 2>>/dev/null; then
		test=NA
	else
		if [ -f /etc/gdm/greeter.dconf-defaults ]; then
			if grep -Eqs '\s*\[org\/gnome\/login-screen\]' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-enable=true\b' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-text=\S+' /etc/gdm/greeter.dconf-defaults; then
				test=passed
			else
				grep -Eqs '\s*\[org\/gnome\/login-screen\]' /etc/gdm/greeter.dconf-defaults || echo "[org/gnome/login-screen]" >> /etc/gdm/greeter.dconf-defaults
				grep -Eqs '^\s*banner-message-enable=true\b' /etc/gdm/greeter.dconf-defaults || echo "banner-message-enable=true" >> /etc/gdm/greeter.dconf-defaults
				grep -Eqs '^\s*banner-message-text=\S+' /etc/gdm/greeter.dconf-defaults || echo "banner-message-text='Authorized uses only. All activity may be monitored and reported.'" >> /etc/gdm/greeter.dconf-defaults
				grep -Eqs '\s*\[org\/gnome\/login-screen\]' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-enable=true\b' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-text=\S+' /etc/gdm/greeter.dconf-defaults && test=remediated
			fi
		else
			echo "[org/gnome/login-screen]" >> /etc/gdm/greeter.dconf-defaults
			echo "banner-message-enable=true" >> /etc/gdm/greeter.dconf-defaults
			echo "banner-message-text='Authorized uses only. All activity may be monitored and reported.'" >> /etc/gdm/greeter.dconf-defaults
			grep -Eqs '\s*\[org\/gnome\/login-screen\]' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-enable=true\b' /etc/gdm/greeter.dconf-defaults && grep -Eqs '^\s*banner-message-text=\S+' /etc/gdm/greeter.dconf-defaults && test=remediated
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
			echo "Recommendation \"$RNA\" Partition doesn't exist - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}