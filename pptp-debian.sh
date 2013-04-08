#!/bin/bash
# from: http://www.ilucong.net/lulu/debian-ubuntu-pptp-vpn.html

subnet="172.16.86"
username='vpn'
password='emacsisgood'

vpsip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`

# check root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear
printf "
####################################################
#                                                  #
# This is a Shell-Based tool of pptp installation  #
# Version: 0.1                                     #
# Author: Bruce Ku Edited by halida                #
# For Debian/Ubuntu 32bit and 64bit                #
#                                                  #
####################################################
"

# install
apt-get update
apt-get --purge -y remove pptpd ppp
rm -rf /etc/pptpd.conf
rm -rf /etc/ppp
apt-get install -y ppp pptpd
apt-get install -y iptables logrotate tar cpio perl

# config
rm -r /dev/ppp
mknod /dev/ppp c 108 0
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip ${subnet}.1" >> /etc/pptpd.conf
echo "remoteip ${subnet}.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options
echo "ms-dns 8.8.4.4" >> /etc/ppp/options
echo "mtu 1400" >> /etc/ppp/options
echo "${username} pptpd ${password} *" >> /etc/ppp/chap-secrets

# config iptable for route
iptables -t nat -A POSTROUTING -s ${subnet}.0/24 -j SNAT --to-source ${vpsip}
iptables -A FORWARD -p tcp --syn -s ${subnet}.0/24 -j TCPMSS --set-mss 1356
iptables -t nat -A POSTROUTING -s ${subnet}.0/24 -j SNAT --to-source "$vpsip"
iptables-save > /etc/iptables-rules
printf "
####################################################
add my Yu
####################################################
"
echo "pre-up iptables-restore < /etc/iptables-rules" >> /etc/network/interfaces
printf "
####################################################
add my Yu
####################################################
"

service pptpd restart
printf "
####################################################
#                                                  #
# This is a Shell-Based tool of pptp installation  #
# Version: 0.1                                     #
# Author: Bruce Ku                                 #
# For Debian/Ubuntu 32bit and 64bit                #
#                                                  #
####################################################
ServerIP:$vpsip
username:${username}
password:${password}

"
