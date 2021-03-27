#!/usr/bin/env sh
#
# CIS-LBK Recommendation Function
# ~/CIS-LBK/functions/recommendations/nix_deb_ensure_ipv4_default_deny_firewall_policy.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/20/20    Recommendation "Ensure default deny firewall policy"
# 
deb_ensure_ipv4_default_deny_firewall_policy()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting $RNA" | tee -a "$LOG" 2>> "$ELOG"
	# Function to create IPv4Tables rules
	load_ipv4tables()
	{
		#!/bin/bash

		# Flush IPtables rules
		iptables -F

		# Ensure default deny firewall policy
		iptables -P INPUT DROP
		iptables -P OUTPUT DROP
		iptables -P FORWARD DROP

		# Ensure loopback traffic is configured
		iptables -A INPUT -i lo -j ACCEPT
		iptables -A OUTPUT -o lo -j ACCEPT
		iptables -A INPUT -s 127.0.0.0/8 -j DROP

		# Ensure outbound and established connections are configured
		iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
		iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
		iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

		# Open inbound ssh connections
		if [ -n "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" ]; then
			if [ "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" != "22" ]; then
				iptables -A INPUT -p tcp --dport "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" -m state --state NEW -j ACCEPT
			else
				iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
			fi
		fi
	}

	test="" test1="" test2="" test3=""
	# Check if Firewalld recommendation is applicable
	[ -z "$FWIN" ] && deb_firewall_chk
	if [ "$FWIN" != "IPt" ]; then
		test=NA
	else
		# Check is package manager is defined
		if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
			nix_package_manager_set
		fi
		if ! $PQ iptables >/dev/null; then
			test=manual
		else
			# Check if there are any rules, if not, load all rules:
			if ! iptables -L; then
				load_ipv4tables
			else
				# IPv4Tables rules already exist
				# Ensure openSSH server port is open inbound if openSSH server is running

				# Open inbound ssh connections
				if [ -n "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" ]; then
					if [ "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" != "22" ]; then
						iptables -A INPUT -p tcp --dport "$(ss -tpln4 | awk '/sshd/ { split($4,a,":"); print a[2]}')" -m state --state NEW -j ACCEPT
					else
						iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
					fi
				else
					# Open custom port set in /etc/ssh/sshd_config
					[ -n "$(grep -E '^/s*[Pp]ort\s+\S+\b' /etc/ssh/sshd_config | awk '{print $2}')" ] && iptables -A INPUT -p tcp --dport "$(grep -E '^/s*[Pp]ort\s+\S+\b' /etc/ssh/sshd_config | awk '{print $2}')" -m state --state NEW -j ACCEPT
				fi
				# Test iptables for defaulp drop policy

				# Test for input policy DROP (test1)
				if iptables -L | grep -Eqs 'Chain INPUT \(policy DROP\)'; then
					test1=passed
				else
					iptables -P INPUT DROP
					iptables -L | grep -Eqs 'Chain INPUT \(policy DROP\)' && test1=remediated
				fi

				# Test for forward policy DROP (test2)
				if iptables -L | grep -Eqs 'Chain FORWARD \(policy DROP\)'; then
					test2=passed
				else
					iptables -P FORWARD DROP
					iptables -L | grep -Eqs 'Chain FORWARD \(policy DROP\)' && test2=remediated
				fi

				# Test for output policy DROP (test3)
				if iptables -L | grep -Eqs 'Chain OUTPUT \(policy DROP\)'; then
					test3=passed
				else
					iptables -P OUTPUT DROP
					iptables -L | grep -Eqs 'Chain OUTPUT \(policy DROP\)' && test3=remediated
				fi

				# Test for output status
				if [ -n "$test1" ] && [ -n "$test2" ] && [ -n "$test3" ]; then
					if [ "$test1" = passed ] && [ "$test2" = passed ] && [ "$test3" = passed ]; then
						test=passed
					else
						test=remediated
					fi
				fi
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
			echo "Recommendation \"$RNA\" Another Firewall is in use on the system - Recommendation is non applicable" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_PASS:-104}"
			;;
		*)
			echo "Recommendation \"$RNA\" remediation failed" | tee -a "$LOG" 2>> "$ELOG"
			return "${XCCDF_RESULT_FAIL:-102}"
			;;
	esac
}