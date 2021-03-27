#!/usr/bin/env sh
#
# CIS-LBK General Function
# ~/CIS-LBK/functions/general/nix_fed_firewall_chk.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       10/06/20    General "Check which firewall is in use"
# 
fed_firewall_chk()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting Firewall Check to determine Firewall in use on the system -" | tee -a "$LOG" 2>> "$ELOG"
	# Firewall Options:
	# Firewalld - FWd
	# NFTables - NFt
	# IPTables - IPt
	FWIN=""

	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi

    # Check FirewallD
    if $PQ firewalld && systemctl status firewalld | grep -q "Active: active (running) " && systemctl is-enabled firewalld | grep -q enabled; then
    	# Firewalld is active on the system, set FWIN to Fwd
    	export FWIN=FWd
        echo "Firewalld is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    fi
    
    # Check NFTables
    if [ -z "$FWIN" ]; then
    	if $PQ nftables && systemctl status nftables | grep -q "Active: active (running) " && systemctl is-enabled nftables | grep -q enabled; then
    		# Firewalld is not active, and NFTables is active, set FWIN to NFt
    		export FWIN=NFt
            echo "NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	fi
    fi

    # Check IPTables
    if [ -z "$FWIN" ]; then
    	# Firewalld and NFTables are not active, check for IPTables rules
    	if [ -n "$(iptables -L)" ] || [ -n "$(ip6tables -L)" ]; then
    		! systemctl is-enabled firewalld | grep -q enabled && ! systemctl is-enabled nftables | grep -q enabled && export FWIN=IPt && echo "IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	fi
    fi

    # If No firewall is fully active, secondary check
    if $PQ firewalld && systemctl is-enabled firewalld | grep -q enabled; then
    	export FWIN=FWd
        echo "Second check, Firewalld is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    elif $PQ nftables && systemctl is-enabled nftables | grep -q enabled; then
    	export FWIN=NFt
        echo "Second check, NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    elif [ -n "$(iptables -L)" ] || [ -n "$(ip6tables -L)" ]; then
    	export FEIN=IPt
        echo "Second check, IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    else
    	# If nothing else passes, check for installed software
    	if $PQ firewalld; then
    		export FWIN=FWd
            echo "Final check, FirewallD is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	elif $PQ nftables; then
    		export FWIN=NFt
            echo "Final check, NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	elif $PQ iptables; then
    		export FWIN=IPt
            echo "Final check, IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	else
    		export FWIN=FWd
            ! $PQ firewalld && $PM -y install firewalld
            if ! grep -Eqs '^\s*AllowZoneDrifting=no' /etc/firewalld/firewalld.conf; then
                grep -q 'AllowZoneDrifting=' /etc/firewalld/firewalld.conf && sed -ri 's/^\s*(#\s*)?([Aa]llow[Zz]one[Dd]rifting\s*=\s*\S+\b)(.*)?$/AllowZoneDrifting=no \3/' /etc/firewalld/firewalld.conf || echo "AllowZoneDrifting=no" >> /etc/firewalld/firewalld.conf
                firewall-cmd --reload
            fi
#            ! systemctl is-enabled firewalld && systemctl unmask firewalld && systemctl --now enable firewalld
#            ! systemctl status firewalld | grep -q 'Active: active (running)' && systemctl start firewalld
#            if systemctl list-unit-files | grep enabled | grep -q ssh; then
#                firewall-cmd --permanent --zone=public --add-service=ssh
#                firewall-cmd --reload
#            fi
            echo "Last option reached, setting firewall to FirewallD" | tee -a "$LOG" 2>> "$ELOG"
    	fi
    fi
    case "$FWIN" in
        FWd)
            echo "Firewall determined to be FirewallD, checks for NFTables and IPTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        NFt)
            echo "Firewall determined to be NFTables, checks for FirewallD and IPTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        IPt)
            echo "Firewall determined to be IPTables, checks for FirewallD and NFTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        *)
            echo "Something didn't work correctly, trying again"
            fed_firewall_chk
            ;;
    esac
    echo "- $(date +%d-%b-%Y' '%T) - Completed Firewall Check to determine Firewall in use on the system -" | tee -a "$LOG" 2>> "$ELOG"
}