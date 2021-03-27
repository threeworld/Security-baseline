#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_fed_ensure_gdm_removed_or_login_banner_configured.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/13/20    Recommendation "Ensure GDM is removed or login is configured"
# 
fed_ensure_gdm_removed_or_login_banner_configured()
{
	test="" test1="" test2="" test3="" test4=""
	# Set package manager information
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi
	# Check if setroubleshoot is not installed
	if ! $PQ gdm 2>>/dev/null; then
		test=NA
	else
		# Check for file "/etc/dconf/profile/gdm"
		if [ -s /etc/dconf/profile/gdm ]; then
			test1=passed
		else
			{ echo "user-db:user"; echo "system-db:gdm"; echo "file-db:/usr/share/gdm/greeter-dconf-defaults"; } >> /etc/dconf/profile/gdm
			[ -e /etc/dconf/profile/gdm ] && test1=remediated
		fi
		# Check enteries in /etc/dconf/profile/gdm file
		if grep -Eq '^\s*user-db:user\b' /etc/dconf/profile/gdm && grep -Eq '^\s*system-db:gdm\b' /etc/dconf/profile/gdm && grep -Eq '^\s*file-db:\/usr\/share\/gdm\/greeter-dconf-defaults\b' /etc/dconf/profile/gdm; then
			test2=passed
		else
			if ! grep -Eq '^\s*user-db:user\b' /etc/dconf/profile/gdm; then
				if grep -Eq '^\s*user-db:' /etc/dconf/profile/gdm; then
					sed -ri 's/(^\s*user-db:)(S+s*)?(.*)$/\1user \3/' /etc/dconf/profile/gdm
				else
					echo "user-db:user" >> /etc/dconf/profile/gdm
				fi
			fi
			if ! grep -Eq '^\s*system-db:gdm\b' /etc/dconf/profile/gdm; then
				if grep -Eq '^\s*system-db:' /etc/dconf/profile/gdm; then
					sed -ri 's/(^\s*system-db:)(\s+\s*)(.*)$/\1gdm \3/' /etc/dconf/profile/gdm
				else
					echo "system-db:gdm" >> /etc/dconf/profile/gdm
				fi
			fi
			if ! grep -Eq '^\s*file-db:\/usr\/share\/gdm\/greeter-dconf-defaults\b' /etc/dconf/profile/gdm; then
				if grep -Eq '^\s*file-db:' /etc/dconf/profile/gdm; then
					sed -ri 's/(^\s*file-db:)(\s+\s*)(.*)$/\1\/usr\/share\/gdm\/greeter-dconf-defaults \3/' /etc/dconf/profile/gdm
				else
					echo "file-db:/usr/share/gdm/greeter-dconf-defaults" >> /etc/dconf/profile/gdm
				fi
			fi
			grep -Eq '^\s*user-db:user\b' /etc/dconf/profile/gdm && grep -Eq '^\s*system-db:gdm\b' /etc/dconf/profile/gdm && grep -Eq '^\s*file-db:\/usr\/share\/gdm\/greeter-dconf-defaults\b' /etc/dconf/profile/gdm && test2=remediated
		fi

		# Check banner
		if [ -d /etc/dconf/db/gdm.d/ ]; then
			for file in $(find /etc/dconf/db/gdm.d/ -maxdepth 1 -type f); do
				if grep -Eq '^\s*\[org\/gnome\/login-screen\]' "$file" && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-enable=true\b' && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-text=\S+'; then
					test3=passed
				else
					if [ "$test3" != "passed" ] && [ "$test3" != "remediated" ] && grep -Eq '^\s*\[org\/gnome\/login-screen\]' "$file"; then
						sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-text=\S+' || sed -ri "/^\s*\[org\/gnome\/login-screen\]/ a\banner-message-text='Authorized uses only. All activity may be monitored and reported.'" "$file"
						sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-enable=true\b' || sed -ri "/^\s*\[org\/gnome\/login-screen\]/ a\banner-message-enable=true" "$file"
						grep -Eq '^\s*\[org\/gnome\/login-screen\]' "$file" && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-enable=true\b' && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-text=\S+' && test3=remediated
					fi
				fi
			done
		fi
		if [ -z "$test3" ]; then
			{ echo "[org/gnome/login-screen]"; echo "banner-message-enable=true"; echo "banner-message-text='Authorized uses only. All activity may be monitored and reported.'"; } >> /etc/dconf/db/gdm.d/01-banner-message
			grep -Eq '^\s*\[org\/gnome\/login-screen\]' /etc/dconf/db/gdm.d/01-banner-message && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' /etc/dconf/db/gdm.d/01-banner-message | grep -Eq '^\s*banner-message-enable=true\b' && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' /etc/dconf/db/gdm.d/01-banner-message | grep -Eq '^\s*banner-message-text=\S+' && test3=remediated
		fi

		# Check Do Not show user list
		# Check banner
		if [ -d /etc/dconf/db/gdm.d/ ]; then
			for file in $(find /etc/dconf/db/gdm.d/ -maxdepth 1 -type f); do
				if grep -Eq '^\s*\[org\/gnome\/login-screen\]' "$file" && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*disable-user-list=true\b'; then
					test4=passed
				else
					if [ "$test4" != "passed" ] && [ "$test4" != "remediated" ] && grep -Eq '^\s*\[org\/gnome\/login-screen\]' "$file"; then
						sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' "$file" | grep -Eq '^\s*banner-message-enable=true\b' || sed -ri "/^\s*\[org\/gnome\/login-screen\]/ a\disable-user-list=true" "$file"
					fi
				fi
			done
		fi
		if [ -z "$test4" ]; then
			{ echo "[org/gnome/login-screen]"; echo "# Do not show the user list"; echo "disable-user-list=true"; } >> /etc/dconf/db/gdm.d/00-login-screen
			grep -Eq '^\s*\[org\/gnome\/login-screen\]' /etc/dconf/db/gdm.d/00-login-screen && sed -nr '/^\s*\[org\/gnome\/login-screen\]/,$p' /etc/dconf/db/gdm.d/00-login-screen | grep -Eq '^\s*disable-user-list=true\b' && test4=remediated
		fi
		# Check test status
		if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ] && [ -n "$test4" ]; then
			if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ] && [ "$test4" = passed ]; then
				test=passed
			else
				dconf update
				test=remediated
			fi
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