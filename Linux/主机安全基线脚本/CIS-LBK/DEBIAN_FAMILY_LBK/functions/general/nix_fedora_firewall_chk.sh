#!/usr/bin/env sh
#
# CIS-LBK general function
# ~/CIS-LBK/functions/general/nix_fedora_firewall_chk.sh
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   08/20/20   Fedora check if firewalld, nftables, iptables, or no firewall is configured
#

fedora_firewall_chk()
{
    firewall_used=""
    # Check FirewallD
    rpm -q | grep -Eq '^firewalld-' && systemctl status firewalld | grep -q "Active: active (running) " && systemctl is-enabled firewalld | grep -q enabled && firewalldia="true"
    # Check if nftables is installed
    rpm -q | grep -Eq '^nftables-' && systemctl status nftables | grep -q "Active: active (running) " && systemctl is-enabled nftables | grep -q enabled && nftablesia="true"
    #check if iptables is installed
    rpm -q | grep -Eq '^iptables-' && iptablesi="true"
    rpm -q | grep -Eq '^iptables-services-' && iptablesservicei="true"
    systemctl status iptables-service | grep -q "Active: active (running) " && systemctl is-enabled iptables-service | grep -q enabled && iptablesservicea="true"
    [ "$iptablesi" = "true" ] && [ "$iptablesservicei" = "true" ] && [ "$iptablesservicea" = "true" ] && iptablesia="true"

    if [ "$firewalldia" != "true" ] && [ "$nftablesia" = "true" ] && [ "$iptablesia" != "true" ]; then
        firewall_used="nftablesiu"
    elif [ "$firewalldia" != "true" ] && [ "$nftablesia" != "true" ] && [ "$iptablesia" = "true" ]; then
        firewall_used="iptablesiu"
    else
        firewall_used="firewalldiu"
    fi
    export firewall_used
}