#!/usr/bin/env bash
#
# CIS-LBK CIS Debian Family Linux Benchmark v1.0.0 Build Kit script
# ~/CIS-LBK/DEBIAN_FAMILY_LBK.sh
# 
# Name                Date       Description
# ------------------------------------------------------------------------------------------------
# Eric Pinnell       12/01/20    Build Kit "CIS Debian Family Linux Benchmark v1.0.0"
#

if [ ! "$BASH_VERSION" ] ; then
	exec /bin/bash "$0" "$@"
fi
# Set global variables
BDIR="$(dirname "$(readlink -f "$0")")"
FDIR=$BDIR/functions
RECDIR="$FDIR"/recommendations
GDIR="$FDIR"/general
LDIR=$BDIR/logs
RDIR=$BDIR/backup
DTG=$(date +%m_%d_%Y_%H%M)
mkdir $LDIR/$DTG
mkdir $RDIR/$DTG
LOGDIR=$LDIR/$DTG
BKDIR=$RDIR/$DTG
LOG=$LOGDIR/CIS-LBK_verbose.log
SLOG=$LOGDIR/CIS-LBK.log
ELOG=$LOGDIR/CIS-LBK_error.log
FRLOG=$LOGDIR/CIS-LBK_failed.log
MANLOG=$LOGDIR/CIS-LBK_manual.log
passed_recommendations="0"
failed_recommendations="0"
remediated_recommendations="0"
not_applicable_recommendations="0"
excluded_recommendations="0"
manual_recommendations="0"
skipped_recommendations="0"
total_recommendations="0"
# Load functions (Order matters)
for func in "$GDIR"/*.sh; do
	[ -e "$func" ] || break
	. "$func"
done
for func in "$RECDIR"/*.sh; do
	[ -e "$func" ] || break
	. "$func"
done

#Clear the screen for output
clear
# Display the build kit banner
BANR
# Ensure script is being run as root
ROOTUSRCK
# Display the terms of use
# terms_of_use
# Display CIS Linux Build Kit warning banner
WARBNR
#run_profile=L2S # Uncomment this line to provide profile to be run manually
# Profile Options:
# L1S - For Level 1 Server
# L1W - For Level 1 Workstation
# L2S - For Level 2 Server
# L2W - For Level 2 Workstation
# Have user select profile to run
select_profile
# Recommediations This is where a BM specific script begins.

# Generated for specific Benchmark

#
# 1 Initial Setup
#
#
# 1.1 Filesystem Configuration
#
#
# 1.1.1 Disable unused filesystems
#
RN="1.1.1.1"
RNA="Ensure mounting of cramfs filesystems is disabled"
profile="L1S L1W"
REC="cramfs_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.2"
RNA="Ensure mounting of freevxfs filesystems is disabled"
profile="L1S L1W"
REC="freevxfs_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.3"
RNA="Ensure mounting of jffs2 filesystems is disabled"
profile="L1S L1W"
REC="jffs2_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.4"
RNA="Ensure mounting of hfs filesystems is disabled"
profile="L1S L1W"
REC="hfs_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.5"
RNA="Ensure mounting of hfsplus filesystems is disabled"
profile="L1S L1W"
REC="hfsplus_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.6"
RNA="Ensure mounting of squashfs filesystems is disabled"
profile="L1S L1W"
REC="squashfs_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.1.7"
RNA="Ensure mounting of udf filesystems is disabled"
profile="L1S L1W"
REC="udf_filesystem_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.2"
RNA="Ensure /tmp is configured"
profile="L1S L1W"
REC="ensure_tmp_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.3"
RNA="Ensure nodev option set on /tmp partition"
profile="L1S L1W"
REC="ensure_nodev_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.4"
RNA="Ensure nosuid option set on /tmp partition"
profile="L1S L1W"
REC="ensure_nosuid_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.5"
RNA="Ensure noexec option set on /tmp partition"
profile="L1S L1W"
REC="ensure_noexec_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.6"
RNA="Ensure separate partition exists for /var"
profile="L2S L2W"
REC="var_partition_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.7"
RNA="Ensure separate partition exists for /var/tmp"
profile="L2S L2W"
REC="var_tmp_partition_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.8"
RNA="Ensure nodev option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_nodev_var_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.9"
RNA="Ensure nosuid option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_nosuid_var_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.10"
RNA="Ensure noexec option set on /var/tmp partition"
profile="L1S L1W"
REC="ensure_noexec_var_tmp"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.11"
RNA="Ensure separate partition exists for /var/log"
profile="L2S L2W"
REC="var_log_partition_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.12"
RNA="Ensure separate partition exists for /var/log/audit"
profile="L2S L2W"
REC="var_log_audit_partition_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.13"
RNA="Ensure separate partition exists for /home"
profile="L2S L2W"
REC="home_partition_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.14"
RNA="Ensure nodev option set on /home partition"
profile="L1S L1W"
REC="ensure_nodev_home"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.15"
RNA="Ensure nodev option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_nodev_dev_shm"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.16"
RNA="Ensure nosuid option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_nosuid_dev_shm"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.17"
RNA="Ensure noexec option set on /dev/shm partition"
profile="L1S L1W"
REC="ensure_noexec_dev_shm"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.18"
RNA="Ensure nodev option set on removable media partitions"
profile="L1S L1W"
REC="ensure_nodev_removable_media"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.19"
RNA="Ensure nosuid option set on removable media partitions"
profile="L1S L1W"
REC="ensure_nosuid_removable_media"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.20"
RNA="Ensure noexec option set on removable media partitions"
profile="L1S L1W"
REC="ensure_noexec_removable_media"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.21"
RNA="Ensure sticky bit is set on all world-writable directories"
profile="L1S L1W"
REC="ensure_stickybit_world_writable_directories"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.22"
RNA="Disable Automounting"
profile="L1S L2W"
REC="disable_automounting"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.1.23"
RNA="Disable USB Storage"
profile="L1S L2W"
REC="disable_usb_storage"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.2 Configure Software Updates
#
RN="1.2.1"
RNA="Ensure package manager repositories are configured"
profile="L1S L1W"
REC="ensure_package_manager_repositories_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.2.2"
RNA="Ensure GPG keys are configured"
profile="L1S L1W"
REC="ensure_gpg_keys_configured"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.3 Configure sudo
#
RN="1.3.1"
RNA="Ensure sudo is installed"
profile="L1S L1W"
REC="ensure_sudo_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.2"
RNA="Ensure sudo commands use pty"
profile="L1S L1W"
REC="ensure_sudo_commands_pty"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.3.3"
RNA="Ensure sudo log file exists"
profile="L1S L1W"
REC="ensure_sudo_logfile_exists"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.4 Filesystem Integrity Checking
#
RN="1.4.1"
RNA="Ensure AIDE is installed"
profile="L1S L1W "
REC="ensure_aide_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.4.2"
RNA="Ensure filesystem integrity is regularly checked"
profile="L1S L1W"
REC="deb_ensure_filesystem_integrity_checked"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.5 Secure Boot Settings
#
RN="1.5.1"
RNA="Ensure permissions on bootloader config are configured"
profile="L1S L1W"
REC="deb_ensure_bootloader_password_set"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.5.2"
RNA="Ensure bootloader password is set"
profile="L1S L1W"
REC="ensure_permissions_bootloader_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.5.3"
RNA="Ensure authentication required for single user mode"
profile="L1S L1W"
REC="deb_ensure_authentication_required_single_user_mode"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6"
RNA="Additional Process Hardening"
profile=""
REC=""
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.1"
RNA="Ensure XD/NX support is enabled"
profile="L1S L1W"
REC="ensure_XD_NX_support_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.2"
RNA="Ensure address space layout randomization (ASLR) is enabled"
profile="L1S L1W"
REC="ensure_aslr_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.3"
RNA="Ensure prelink is disabled"
profile="L1S L1W"
REC="ensure_prelink_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.6.4"
RNA="Ensure core dumps are restricted"
profile="L1S L1W"
REC="core_dumps_restricted"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.7 Mandatory Access Control
#
#
# 1.7.1 Configure AppArmor
#
RN="1.7.1.1"
RNA="Ensure AppArmor is installed"
profile="L1S L1W"
REC="deb_ensure_apparmor_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.1.2"
RNA="Ensure AppArmor is enabled in the bootloader configuration"
profile="L1S L1W"
REC="deb_ensure_apparmor_enabled_bootloader_configuration"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.1.3"
RNA="Ensure all AppArmor Profiles are in enforce or complain mode"
profile="L1S L1W"
REC="deb_ensure_apparmor_profiles_in_enforce_or_complain_mode"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.7.1.4"
RNA="Ensure all AppArmor Profiles are enforcing"
profile="L2S L2W"
REC="deb_ensure_apparmor_profiles_are_enforcing"
total_recommendations=$((total_recommendations+1))
runrec

#
# 1.8 Warning Banners
#
RN="1.8.1"
RNA="Ensure message of the day is configured properly"
profile="L1S L1W"
REC="nix_ensure_motd_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.2"
RNA="Ensure permissions on /etc/issue.net are configured"
profile="L1S L1W"
REC="nix_ensure_local_login_warning_banner_configured_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.3"
RNA="Ensure permissions on /etc/issue are configured"
profile="L1S L1W"
REC="nix_ensure_remote_login_warning_banner_configured_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.4"
RNA="Ensure permissions on /etc/motd are configured"
profile="L1S L1W"
REC="nix_ensure_permissions_motd_configured_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.5"
RNA="Ensure remote login warning banner is configured properly"
profile="L1S L1W"
REC="nix_ensure_permissions_issue_configured_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.8.6"
RNA="Ensure local login warning banner is configured properly"
profile="L1S L1W"
REC="nix_ensure_permissions_issue_net_configured_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.9"
RNA="Ensure GDM is removed or login is configured"
profile="L1S L1W"
REC="deb_ensure_gdm_login_banner_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="1.10"
RNA="Ensure updates patches and additional security software are installed"
profile="L1S L1W"
REC="deb_ensure_updates_patches_additional_security_software_installed"
total_recommendations=$((total_recommendations+1))
runrec

#
# 2 Services
#
#
# 2.1 Special Purpose Services
#
#
# 2.1.1 Time Synchronization
#
RN="2.1.1.1"
RNA="Ensure time synchronization is in use"
profile="L1S L1W"
REC="deb_ensure_time_synchronization_in_use"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.1.2"
RNA="Ensure systemd-timesyncd is configured"
profile="L1S L1W"
REC="deb_ensure_systemd-timesyncd_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.1.3"
RNA="Ensure chrony is configured"
profile="L1S L1W"
REC="deb_chrony_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.1.4"
RNA="Ensure ntp is configured"
profile="L1S L1W"
REC="deb_ensure_ntp_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.2"
RNA="Ensure X Window System is not installed"
profile="L1S"
REC="deb_ensure_xwindows_system_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.3"
RNA="Ensure Avahi Server is not installed"
profile="L1S L1W"
REC="deb_ensure_avahi_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.4"
RNA="Ensure CUPS is not installed"
profile="L1S L2W"
REC="ensure_cups_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.5"
RNA="Ensure DHCP Server is not installed"
profile="L1S L1W"
REC="deb_ensure_dhcp_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.6"
RNA="Ensure LDAP server is not installed"
profile="L1S L1W"
REC="deb_ensure_ldap_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.7"
RNA="Ensure NFS is not installed"
profile="L1S L1W"
REC="deb_ensure_nfs_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.8"
RNA="Ensure DNS Server is not installed"
profile="L1S L1W"
REC="deb_ensure_dns_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.9"
RNA="Ensure FTP Server is not installed"
profile="L1S L1W"
REC="ensure_ftp_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.10"
RNA="Ensure HTTP server is not installed"
profile="L1S L1W"
REC="deb_ensure_http_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.11"
RNA="Ensure IMAP and POP3 server are not installed"
profile="L1S L1W"
REC="deb_ensure_imap_pop3_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.12"
RNA="Ensure Samba is not installed"
profile="L1S L1W"
REC="ensure_samba_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.13"
RNA="Ensure HTTP Proxy Server is not installed"
profile="L1S L1W"
REC="ensure_http_proxy_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.14"
RNA="Ensure SNMP Server is not installed"
profile="L1S L1W"
REC="deb_ensure_snmp_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.15"
RNA="Ensure mail transfer agent is configured for local-only mode"
profile="L1S L1W"
REC="ensure_mail_transfer_agent_configured_local_only"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.16"
RNA="Ensure rsync service is not installed"
profile="L1S L1W"
REC="deb_ensure_rsync_service_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.1.17"
RNA="Ensure NIS Server is not installed"
profile="L1S L1W"
REC="deb_ensure_nis_server_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

#
# 2.2 Service Clients
#
RN="2.2.1"
RNA="Ensure NIS Client is not installed"
profile="L1S L1W"
REC="deb_ensure_nis_client_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.2"
RNA="Ensure rsh client is not installed"
profile="L1S L1W"
REC="deb_ensure_rsh_client_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.3"
RNA="Ensure talk client is not installed"
profile="L1S L1W"
REC="ensure_talk_client_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.4"
RNA="Ensure telnet client is not installed"
profile="L1S L1W"
REC="ensure_telnet_client_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.5"
RNA="Ensure LDAP client is not installed"
profile="L1S L1W"
REC="deb_ensure_ldap_client_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.2.6"
RNA="Ensure  RPC is not installed"
profile="L1S L1W"
REC="deb_ensure_rpc_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="2.3"
RNA="Ensure nonessential services are removed or masked"
profile="L1S L1W"
REC="ensure_nonessential_services_removed_or_masked"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3 Network Configuration
#
#
# 3.1 Disable unused network protocols and devices
#
RN="3.1.1"
RNA="Disable IPv6"
profile="L2S L2W"
REC="disable_ipv6"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.1.2"
RNA="Ensure wireless interfaces are disabled"
profile="L1S L1W"
REC="ensure_wireless_interfaces_disabled"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.2 Network Parameters (Host Only)
#
RN="3.2.1"
RNA="Ensure packet redirect sending is disabled"
profile="L1S L1W"
REC="packet_redirect_sending_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.2.2"
RNA="Ensure IP forwarding is disabled"
profile="L1S L1W"
REC="ip_forwarding_disabled"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.3 Network Parameters (Host and Router)
#
RN="3.3.1"
RNA="Ensure source routed packets are not accepted"
profile="L1S L1W"
REC="ensure_source_routed_packets_not_accepted"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.2"
RNA="Ensure ICMP redirects are not accepted"
profile="L1S L1W"
REC="ensure_icmp_redirects_not_accepted"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.3"
RNA="Ensure secure ICMP redirects are not accepted"
profile="L1S L1W"
REC="ensure_secure_icmp_redirects_not_accepted"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.4"
RNA="Ensure suspicious packets are logged"
profile="L1S L1W"
REC="ensure_suspicious_packets_logged"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.5"
RNA="Ensure broadcast ICMP requests are ignored"
profile="L1S L1W"
REC="ensure_broadcast_icmp_requests_ignored"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.6"
RNA="Ensure bogus ICMP responses are ignored"
profile="L1S L1W"
REC="nix_ensure_bogus_icmp_responses_ignored"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.7"
RNA="Ensure Reverse Path Filtering is enabled"
profile="L1S L1W"
REC="ensure_reverse_path_filtering_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.8"
RNA="Ensure TCP SYN Cookies is enabled"
profile="L1S L1W"
REC="ensure_tcp_syn_cookies_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.3.9"
RNA="Ensure IPv6 router advertisements are not accepted"
profile="L1S L1W"
REC="ensure_ipv6_router_advertisements_not_accepted"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.5 Uncommon Network Protocols
#
RN="3.5.1"
RNA="Ensure DCCP is disabled"
profile="L2S L2W"
REC="ensure_dccp_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.5.2"
RNA="Ensure SCTP is disabled"
profile="L2S L2W"
REC="ensure_sctp_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.5.3"
RNA="Ensure RDS is disabled"
profile="L2S L2W"
REC="ensure_rds_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.5.4"
RNA="Ensure TIPC is disabled"
profile="L2S L2W"
REC="ensure_tipc_disabled"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.6 Firewall Configuration
#
#
# 3.6.1 Configure UncomplicatedFirewall
#
RN="3.6.1.1"
RNA="Ensure Uncomplicated Firewall is installed"
profile="L1S L1W"
REC="deb_ensure_uncomplicated_firewall_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.2"
RNA="Ensure iptables-persistent is not installed"
profile="L1S L1W"
REC="deb_ensure_iptables_persistent_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.3"
RNA="Ensure ufw service is enabled"
profile="L1S L1W"
REC="deb_ensure_ufw_service_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.4"
RNA="Ensure loopback traffic is configured"
profile="L1S L1W"
REC="deb_ensure_ufw_loopback_traffic_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.5"
RNA="Ensure outbound connections are configured"
profile="L1S L1W"
REC="deb_ensure_outbound_connections_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.6"
RNA="Ensure firewall rules exist for all open ports"
profile="L1S L1W"
REC="deb_ensure_firewall_rules_exist_all_open_ports"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.1.7"
RNA="Ensure default deny firewall policy"
profile="L1S L1W"
REC="deb_ensure_default_deny_firewall_policy"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.6.2 Configure nftables
#
RN="3.6.2.1"
RNA="Ensure nftables is installed"
profile="L1S L1W"
REC="deb_ensure_nftables_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.2"
RNA="Ensure Uncomplicated Firewall is not installed or disabled"
profile="L1S L1W"
REC="deb_ensure_ufw_not_installed_or_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.3"
RNA="Ensure iptables are flushed"
profile="L1S L1W"
REC="deb_ensure_iptables_flushed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.4"
RNA="Ensure a table exists"
profile="L1S L1W"
REC="deb_ensure_table_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.5"
RNA="Ensure base chains exist"
profile="L1S L1W"
REC="deb_ensure_base_chains_exists"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.6"
RNA="Ensure loopback traffic is configured"
profile="L1S L1W"
REC="deb_nft_ensure_loopback_traffic_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.7"
RNA="Ensure outbound and established connections are configured"
profile="L1S L1W"
REC="deb_nft_ensure_outbound_established_connections_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.8"
RNA="Ensure default deny firewall policy"
profile="L1S L1W"
REC="deb_nft_ensure_default_deny_firewall_policy"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.9"
RNA="Ensure nftables service is enabled"
profile="L1S L1W"
REC="deb_ensure_nftables_service_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.2.10"
RNA="Ensure nftables rules are permanent"
profile="L1S L1W"
REC="deb_ensure_nftables_rules_permanent"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.6.3 Configure iptables
#
#
# 3.6.3.1 Configure software
#
RN="3.6.3.1.1"
RNA="Ensure iptables packages are installed"
profile="L1S L1W"
REC="deb_ensure_iptables_packages_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.1.2"
RNA="Ensure nftables is not installed"
profile="L1S L1W"
REC="deb_ensure_nftables_not_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.1.3"
RNA="Ensure Uncomplicated Firewall is not installed or disabled"
profile="L1S L1W"
REC="deb_ensure_ufw_not_installed_or_disabled"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.6.3.2 Configure IPv4 iptables
#
RN="3.6.3.2.1"
RNA="Ensure default deny firewall policy"
profile="L1S L1W"
REC="deb_ensure_ipv4_default_deny_firewall_policy"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.2.2"
RNA="Ensure loopback traffic is configured"
profile="L1S L1W"
REC="deb_ensure_ipv4_loopback_traffic_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.2.3"
RNA="Ensure outbound and established connections are configured"
profile="L1S L1W"
REC="deb_ensure_ipv4_outbound_and_established_connections_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.2.4"
RNA="Ensure firewall rules exist for all open ports"
profile="L1S L1W"
REC="deb_ensure_ipv4_firewall_rules_exist_all_open_ports"
total_recommendations=$((total_recommendations+1))
runrec

#
# 3.6.3.3 Configure IPv6  ip6tables
#
RN="3.6.3.3.1"
RNA="Ensure IPv6 default deny firewall policy"
profile="L1S L1W"
REC="deb_ensure_ipv6_default_deny_firewall_policy"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.3.2"
RNA="Ensure IPv6 loopback traffic is configured"
profile="L1S L1W"
REC="deb_ensure_ipv6_loopback_traffic_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.3.3"
RNA="Ensure IPv6 outbound and established connections are configured"
profile="L1S L1W"
REC="deb_ensure_ipv6_outbound_and_established_connections_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="3.6.3.3.4"
RNA="Ensure IPv6 firewall rules exist for all open ports"
profile="L1S L1W"
REC="deb_ensure_ipv6_firewall_rules_exist_all_open_ports"
total_recommendations=$((total_recommendations+1))
runrec

#
# 4 Logging and Auditing
#
#
# 4.1 Configure System Accounting (auditd)
#
#
# 4.1.1 Ensure auditing is enabled
#
RN="4.1.1.1"
RNA="Ensure auditd is installed"
profile="L2S L2W"
REC="deb_ensure_auditd_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.1.2"
RNA="Ensure auditd service is enabled"
profile="L2S L2W"
REC="ensure_auditd_service_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.1.3"
RNA="Ensure auditing for processes that start prior to auditd is enabled"
profile="L2S L2W"
REC="ensure_auditing_processes_start_prior_auditd_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.1.4"
RNA="Ensure audit_backlog_limit is sufficient"
profile="L2S L2W"
REC="ensure_audit_backlog_limit_sufficient"
total_recommendations=$((total_recommendations+1))
runrec

#
# 4.1.2 Configure Data Retention
#
RN="4.1.2.1"
RNA="Ensure audit log storage size is configured"
profile="L2S L2W"
REC="ensure_audit_log_storage_size_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.2.2"
RNA="Ensure audit logs are not automatically deleted"
profile="L2S L2W"
REC="ensure_audit_logs_not_automatically_deleted"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.2.3"
RNA="Ensure system is disabled when audit logs are full"
profile="L2S L2W"
REC="ensure_system_disabled_audit_logs_full"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.3"
RNA="Ensure events that modify date and time information are collected"
profile="L2S L2W"
REC="ensure_events_modify_date_time_information_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.4"
RNA="Ensure events that modify user/group information are collected"
profile="L2S L2W"
REC="ensure_events_modify_user_group_information_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.5"
RNA="Ensure events that modify the systems network environment are collected"
profile="L2S L2W"
REC="ensure_events_modify_systems_network_environment_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.6"
RNA="Ensure events that modify the systems Mandatory Access Controls are collected"
profile="L2S L2W"
REC="deb_ensure_events_modify_systems_mac_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.7"
RNA="Ensure login and logout events are collected"
profile="L2S L2W"
REC="deb_ensure_login_logout_events_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.8"
RNA="Ensure session initiation information is collected"
profile="L2S L2W"
REC="ensure_session_initiation_information_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.9"
RNA="Ensure discretionary access control permission modification events are collected"
profile="L2S L2W"
REC="ensure_dac_permission_modification_events_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.10"
RNA="Ensure unsuccessful unauthorized file access attempts are collected"
profile="L2S L2W"
REC="ensure_unsuccessful_unauthorized_file_access_attempts_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.11"
RNA="Ensure use of privileged commands is collected"
profile="L2S L2W"
REC="ensure_use_privileged_commands_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.12"
RNA="Ensure successful file system mounts are collected"
profile="L2S L2W"
REC="ensure_successful_file_system_mounts_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.13"
RNA="Ensure file deletion events by users are collected"
profile="L2S L2W"
REC="ensure_file_deletion_events_by_users_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.14"
RNA="Ensure changes to system administration scope (sudoers) is collected"
profile="L2S L2W"
REC="ensure_changes_sudoers_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.15"
RNA="Ensure system administrator command executions (sudo) are collected"
profile="L2S L2W"
REC="ensure_system_administrator_command_executions_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.16"
RNA="Ensure kernel module loading and unloading is collected"
profile="L2S L2W"
REC="ensure_kernel_module_loading_unloading_collected"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.1.17"
RNA="Ensure the audit configuration is immutable"
profile="L2S L2W"
REC="ensure_audit_configuration_immutable"
total_recommendations=$((total_recommendations+1))
runrec

#
# 4.2 Configure Logging
#
RN="4.2.1"
RNA="Configure rsyslog"
profile=""
REC=""
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.1"
RNA="Ensure rsyslog is installed"
profile="L1S L1W"
REC="ensure_rsyslog_installed"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.2"
RNA="Ensure rsyslog Service is enabled"
profile="L1S L1W"
REC="ensure_rsyslog_service_enabled_running"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.3"
RNA="Ensure logging is configured"
profile="L1S L1W"
REC="ensure_logging_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.4"
RNA="Ensure rsyslog default file permissions configured"
profile="L1S L1W"
REC="ensure_rsyslog_default_file_permissions_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.5"
RNA="Ensure rsyslog is configured to send logs to a remote log host"
profile="L1S L1W"
REC="ensure_rsyslog_configured_send_logs_remote_host"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.1.6"
RNA="Ensure remote rsyslog messages are only accepted on designated log hosts."
profile="L1S L1W"
REC="ensure_remote_rsyslog_messages_only_accepted_designated_host"
total_recommendations=$((total_recommendations+1))
runrec

#
# 4.2.2 Configure journald
#
RN="4.2.2.1"
RNA="Ensure journald is configured to send logs to rsyslog"
profile="L1S L1W"
REC="ensure_journald_configured_send_logs_rsyslog"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.2.2"
RNA="Ensure journald is configured to compress large log files"
profile="L1S L1W"
REC="ensure_journald_configured_compress_large_files"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.2.3"
RNA="Ensure journald is configured to write logfiles to persistent disk"
profile="L1S L1W"
REC="ensure_journald_configured_write_logfiles_disk"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.2.3"
RNA="Ensure permissions on all logfiles are configured"
profile="L1S L1W"
REC="ensure_permissions_on_logfiles_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.3"
RNA="Ensure logrotate is configured"
profile="L1S L1W"
REC="ensure_logrotate_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="4.4"
RNA="Ensure logrotate assigns appropriate permissions"
profile="L1S L1W"
REC="ensure_logrotate_assigns_appropriate_permissions"
total_recommendations=$((total_recommendations+1))
runrec

#
# 5 Access Authentication and Authorization
#
#
# 5.1 Configure time-based job schedulers
#
RN="5.1.1"
RNA="Ensure cron daemon is enabled and running"
profile="L1S L1W"
REC="deb_ensure_cron_daemon_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.2"
RNA="Ensure permissions on /etc/crontab are configured"
profile="L1S L1W"
REC="ensure_permissions_crontab_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.3"
RNA="Ensure permissions on /etc/cron.hourly are configured"
profile="L1S L1W"
REC="ensure_permissions_cron_hourly_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.4"
RNA="Ensure permissions on /etc/cron.daily are configured"
profile="L1S L1W"
REC="ensure_permissions_cron_daily_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.5"
RNA="Ensure permissions on /etc/cron.weekly are configured"
profile="L1S L1W"
REC="ensure_permissions_cron_weekly_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.6"
RNA="Ensure permissions on /etc/cron.monthly are configured"
profile="L1S L1W"
REC="ensure_permissions_cron_monthly_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.7"
RNA="Ensure permissions on /etc/cron.d are configured"
profile="L1S L1W"
REC="ensure_permissions_cron_d_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.8"
RNA="Ensure cron is restricted to authorized users"
profile="L1S L1W"
REC="ensure_cron_restricted_authorized_users"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.1.9"
RNA="Ensure at is restricted to authorized users"
profile="L1S L1W"
REC="ensure_at_restricted_authorized_users"
total_recommendations=$((total_recommendations+1))
runrec

#
# 5.2 Configure SSH Server
#
RN="5.2.1"
RNA="Ensure permissions on /etc/ssh/sshd_config are configured"
profile="L1S L1W"
REC="ensure_permissions_sshd_config_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.2"
RNA="Ensure permissions on SSH private host key files are configured"
profile="L1S L1W"
REC="ensure_permissions_ssh_private_hostkey_files_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.3"
RNA="Ensure permissions on SSH public host key files are configured"
profile="L1S L1W"
REC="ensure_permissions_ssh_public_hostkey_files_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.4"
RNA="Ensure SSH LogLevel is appropriate"
profile="L1S L1W"
REC="ensure_ssh_loglevel_appropriate"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.5"
RNA="Ensure SSH X11 forwarding is disabled"
profile="L2S L1W"
REC="ensure_ssh_x11_forwarding_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.6"
RNA="Ensure SSH MaxAuthTries is set to 4 or less"
profile="L1S L1W"
REC="ensure_ssh_maxauthtries_4_or_less"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.7"
RNA="Ensure SSH IgnoreRhosts is enabled"
profile="L1S L1W"
REC="ensure_ssh_ignorerhosts_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.8"
RNA="Ensure SSH HostbasedAuthentication is disabled"
profile="L1S L1W"
REC="ensure_ssh_hostbasedauthentication_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.9"
RNA="Ensure SSH root login is disabled"
profile="L1S L1W"
REC="ensure_ssh_root_login_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.10"
RNA="Ensure SSH PermitEmptyPasswords is disabled"
profile="L1S L1W"
REC="ensure_ssh_permitemptypasswords_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.11"
RNA="Ensure SSH PermitUserEnvironment is disabled"
profile="L1S L1W"
REC="ensure_ssh_permituserenvironment_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.12"
RNA="Ensure only strong Ciphers are used"
profile="L1S L1W"
REC="ssh7_ensure_strong_ciphers_used"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.13"
RNA="Ensure only strong MAC algorithms are used"
profile="L1S L1W"
REC="ssh7_ensure_strong_mac_algorithms_used"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.14"
RNA="Ensure only strong Key Exchange algorithms are used"
profile="L1S L1W"
REC="ssh7_ensure_strong_key_exchange_algorithms_used"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.15"
RNA="Ensure SSH Idle Timeout Interval is configured"
profile="L1S L1W"
REC="fed28_ensure_ssh_idle_timeout_interval_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.16"
RNA="Ensure SSH LoginGraceTime is set to one minute or less"
profile="L1S L1W"
REC="ensure_ssh_logingracetime_one_minute_or_less"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.17"
RNA="Ensure SSH access is limited"
profile="L1S L1W"
REC="ensure_ssh_access_limited"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.18"
RNA="Ensure SSH warning banner is configured"
profile="L1S L1W"
REC="ensure_ssh_warning_banner_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.19"
RNA="Ensure SSH PAM is enabled"
profile="L1S L1W"
REC="ensure_ssh_pam_enabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.20"
RNA="Ensure SSH AllowTcpForwarding is disabled"
profile="L1S L1W"
REC="ensure_ssh_allowtcpforwarding_disabled"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.21"
RNA="Ensure SSH MaxStartups is configured"
profile="L1S L1W"
REC="ensure_ssh_warning_maxstartups_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.2.22"
RNA="Ensure SSH MaxSessions is limited"
profile="L1S L1W"
REC="ensure_ssh_maxsessions_limited"
total_recommendations=$((total_recommendations+1))
runrec

#
# 5.3 Configure PAM
#
RN="5.3.1"
RNA="Ensure password creation requirements are configured"
profile="L1S L1W"
REC="deb_ensure_password_creation_requirements_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.2"
RNA="Ensure lockout for failed password attempts is configured"
profile="L1S L1W"
REC="deb_ensure_lockout_failed_password_attempts_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.3"
RNA="Ensure password reuse is limited"
profile="L1S L1W"
REC="deb_ensure_password_reuse_limited"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.3.4"
RNA="Ensure password hashing algorithm is SHA-512"
profile="L1S L1W"
REC="deb_ensure_password_hashing_algorithm_sha512"
total_recommendations=$((total_recommendations+1))
runrec

#
# 5.4 User Accounts and Environment
#
#
# 5.4.1 Set Shadow Password Suite Parameters
#
RN="5.4.1.1"
RNA="Ensure password expiration is 365 days or less"
profile="L1S L1W"
REC="password_expiration_365_days_less"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.2"
RNA="Ensure minimum days between password changes is  configured"
profile="L1S L1W"
REC="ensure_minimum_days_between_password_changes_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.3"
RNA="Ensure password expiration warning days is 7 or more"
profile="L1S L1W"
REC="ensure_expiration_warning_days_7_more"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.4"
RNA="Ensure inactive password lock is 30 days or less"
profile="L1S L1W"
REC="ensure_inactive_password_lock_30_days_less"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.1.5"
RNA="Ensure all users last password change date is in the past"
profile="L1S L1W"
REC="ensure_all_users_last_password_change_in_past"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.2"
RNA="Ensure system accounts are secured"
profile="L1S L1W"
REC="ensure_system_accounts_secured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.3"
RNA="Ensure default group for the root account is GID 0"
profile="L1S L1W"
REC="ensure_default_group_for_root_gid_0"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.4"
RNA="Ensure default user umask is 027 or more restrictive"
profile="L1S L1W"
REC="ensure_default_user_umask_027_more_restrictive_v2"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.4.5"
RNA="Ensure default user shell timeout is 900 seconds or less"
profile="L1S L1W"
REC="ensure_default_user_shell_timeout_configured"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.5"
RNA="Ensure root login is restricted to system console"
profile="L1S L1W"
REC="ensure_root_login_restricted_system_console"
total_recommendations=$((total_recommendations+1))
runrec

RN="5.6"
RNA="Ensure access to the su command is restricted"
profile="L1S L1W"
REC="deb_ensure_access_su_command_restricted"
total_recommendations=$((total_recommendations+1))
runrec

#
# 6 System Maintenance
#
#
# 6.1 System File Permissions
#
RN="6.1.1"
RNA="Audit system file permissions"
profile="L2S L2W"
REC="audit_system_file_permissions"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.2"
RNA="Ensure permissions on /etc/passwd are configured"
profile="L1S L1W"
REC="ensure_perms_etc_passwd_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.3"
RNA="Ensure permissions on /etc/passwd- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_passwd_dash_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.4"
RNA="Ensure permissions on /etc/group are configured"
profile="L1S L1W"
REC="ensure_perms_etc_group_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.5"
RNA="Ensure permissions on /etc/group- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_group_dash_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.6"
RNA="Ensure permissions on /etc/shadow are configured"
profile="L1S L1W"
REC="ensure_perms_etc_shadow_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.7"
RNA="Ensure permissions on /etc/shadow- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_shadow_dash_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.8"
RNA="Ensure permissions on /etc/gshadow are configured"
profile="L1S L1W"
REC="ensure_perms_etc_gshadow_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.9"
RNA="Ensure permissions on /etc/gshadow- are configured"
profile="L1S L1W"
REC="ensure_perms_etc_gshadow_dash_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.10"
RNA="Ensure no world writable files exist"
profile="L1S L1W"
REC="no_world_writable_files_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.11"
RNA="Ensure no unowned files or directories exist"
profile="L1S L1W"
REC="no_ungrouped_files_dirs_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.12"
RNA="Ensure no ungrouped files or directories exist"
profile="L1S L1W"
REC="no_ungrouped_files_dirs_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.13"
RNA="Audit SUID executables"
profile="L1S L1W"
REC="audit_suid_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.1.14"
RNA="Audit SGID executables"
profile="L1S L1W"
REC="audit_sgid_fct"
total_recommendations=$((total_recommendations+1))
runrec

#
# 6.2 User and Group Settings
#
RN="6.2.1"
RNA="Ensure accounts in /etc/passwd use shadowed passwords"
profile="L1S L1W"
REC="ensure_accounts_in_etc_passwd_use_shadowed_passwords"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.2"
RNA="Ensure password fields are not empty"
profile="L1S L1W"
REC="nonempty_pw_fields_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.3"
RNA="Ensure all users home directories exist"
profile="L1S L1W"
REC="ensure_users_home_directories_exist"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.4"
RNA="Ensure users own their home directories"
profile="L1S L1W"
REC="ensure_users_own_their_home_directories"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.5"
RNA="Ensure users home directories permissions are 750 or more restrictive"
profile="L1S L1W"
REC="restrictive_home_dir_check_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.6"
RNA="Ensure users dot files are not group or world writable"
profile="L1S L1W"
REC="ensure_users_dot_files_not_group_world_writable"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.7"
RNA="Ensure no users have .netrc files"
profile="L1S L1W"
REC="ensure_no_users_have_dot_netrc_files"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.8"
RNA="Ensure no users have .forward files"
profile="L1S L1W"
REC="ensure_no_users_have_dot_forward_files"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.9"
RNA="Ensure no users have .rhosts files"
profile="L1S L1W"
REC="ensure_no_users_have_dot_rhosts_files"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.10"
RNA="Ensure root is the only UID 0 account"
profile="L1S L1W"
REC="root_only_uid_0_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.11"
RNA="Ensure root PATH Integrity"
profile="L1S L1W"
REC="root_path_integrity_fct"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.12"
RNA="Ensure all groups in /etc/passwd exist in /etc/group"
profile="L1S L1W"
REC="ensure_all_groups_etc_passwd_exist_etc_group"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.13"
RNA="Ensure no duplicate UIDs exist"
profile="L1S L1W"
REC="ensure_no_duplicate_uid_exist"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.14"
RNA="Ensure no duplicate GIDs exist"
profile="L1S L1W"
REC="ensure_no_duplicate_gid_exist"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.15"
RNA="Ensure no duplicate user names exist"
profile="L1S L1W"
REC="ensure_no_duplicate_user_names_exist"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.16"
RNA="Ensure no duplicate group names exist"
profile="L1S L1W"
REC="ensure_no_duplicate_group_names_exist"
total_recommendations=$((total_recommendations+1))
runrec

RN="6.2.17"
RNA="Ensure shadow group is empty"
profile="L1S L1W"
REC="ensure_shadow_group_empty"
total_recommendations=$((total_recommendations+1))
runrec

# End of generation for specific Benchmark
#End of recommendations

# Update grub.cfg permissions (again)
[ -e /boot/grub/grub.cfg ] && chmod og-rwx /boot/grub/grub.cfg
[ -e /boot/grub2/grub.cfg ] && chmod og-rwx /boot/grub2/grub.cfg

# Provide summery report
summery_report
