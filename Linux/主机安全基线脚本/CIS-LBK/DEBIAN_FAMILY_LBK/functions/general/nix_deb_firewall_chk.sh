#!/usr/bin/env sh
#
# CIS-LBK General Function
# ~/CIS-LBK/functions/general/nix_deb_firewall_chk.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       11/19/20    General "Check which firewall is in use"
# Eric Pinnell       11/30/20    Modified - Fixed typo that could cause loop condition
# 
deb_firewall_chk()
{
	echo "- $(date +%d-%b-%Y' '%T) - Starting Firewall Check to determine Firewall in use on the system -" | tee -a "$LOG" 2>> "$ELOG"
	# Firewall Options:
	# UncomplicatedFirewall - UFw
	# NFTables              - NFt
	# IPTables              - IPt
	FWIN=""

	# Check is package manager is defined
	if [ -z "$PQ" ] || [ -z "$PM" ] || [ -z "$PR" ]; then
		nix_package_manager_set
	fi

    # Check UncomplicatedFirewall
    if $PQ ufw >/dev/null && systemctl status ufw | grep -q 'Active: active (\(running\)|\(exited\)) ' && ufw status | grep -q 'Status: active'; then
    	# UncomplicatedFirewall is active on the system, set FWIN to UFw
    	export FWIN=UFw
        echo "UncomplicatedFirewall is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    fi
    
    # Check NFTables
    if [ -z "$FWIN" ]; then
    	if $PQ nftables >/dev/null && systemctl status nftables | grep -Eq "Active: active (\(running\)|\(exited\)) " && systemctl is-enabled nftables | grep -q enabled; then
    		# UncomplicatedFirewall is not active, and NFTables is active, set FWIN to NFt
    		export FWIN=NFt
            echo "NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
    	fi
    fi

    # Check IPTables
    if [ -z "$FWIN" ]; then
    	# Firewalld and NFTables are not active, check for IPTables rules
    	if [ -n "$(iptables -L)" ] || [ -n "$(ip6tables -L)" ]; then
    		if ! systemctl is-enabled ufw | grep -q enabled && ! systemctl is-enabled nftables | grep -q enabled; then
                export FWIN=IPt
                "IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
            fi
    	fi
    fi

    # If No firewall is fully active, secondary check
    if [ -z "$FWIN" ]; then
        if $PQ ufw >/dev/null && systemctl is-enabled ufw | grep -q enabled; then
        	export FWIN=UFw
            echo "Second check, UncomplicatedFirewall is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        elif $PQ nftables && systemctl is-enabled nftables | grep -q enabled; then
        	export FWIN=NFt
            echo "Second check, NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        elif [ -n "$(iptables -L)" ] || [ -n "$(ip6tables -L)" ]; then
        	export FEIN=IPt
            echo "Second check, IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        fi
    fi

    # If nothing else passes, check for installed software
    if [ -z "$FWIN" ]; then
        if $PQ ufw >/dev/null; then
            export FWIN=UFw
            echo "Final check,UncomplicatedFirewall is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        elif $PQ nftables; then
            export FWIN=NFt
            echo "Final check, NFTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        elif $PQ iptables; then
            export FWIN=IPt
            echo "Final check, IPTables is in use on the system" | tee -a "$LOG" 2>> "$ELOG"
        fi
    fi

    # If Nothing else has passed, Install UncomplicatedFirewall and set FWIN to UFw
    if [ -z "$FWIN" ]; then
        echo "Last option reached, setting firewall to UncomplicatedFirewall" | tee -a "$LOG" 2>> "$ELOG"
        if ! $PQ ufw >/dev/null; then
            echo "Installing UncomplicatedFirewall Package" | tee -a "$LOG" 2>> "$ELOG"
            $PM -y install ufw
            export FWIN=UFw
        fi
    fi

    case "$FWIN" in
        UFw)
            echo "Firewall determined to be UncomplicatedFirewall, checks for NFTables and IPTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        NFt)
            echo "Firewall determined to be NFTables, checks for UncomplicatedFirewall and IPTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        IPt)
            echo "Firewall determined to be IPTables, checks for UncomplicatedFirewall and NFTables will be marked as Non Applicable" | tee -a "$LOG" 2>> "$ELOG"
            ;;
        *)
            echo "Something didn't work correctly, trying again"
            deb_firewall_chk
            ;;
    esac
    echo "- $(date +%d-%b-%Y' '%T) - Completed Firewall Check to determine Firewall in use on the system -" | tee -a "$LOG" 2>> "$ELOG"
}