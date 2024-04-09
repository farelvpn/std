#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }




clear
prtt="$(cat /root/log-install.txt | grep -w "XRAY  Vmess Grpc" | cut -d: -f2|sed 's/ //g')"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     ⇱ Change Port Vmess Grpc ⇲    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "      Change Port $prtt"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "New Port Vmess Grpc: " prtt2
if [ -z $prtt2 ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $prtt2)
sed -i "s/: $prtt/: $prtt2/g" /etc/xray/vmessgrpc.json
sed -i "s/   - XRAY  Vmess Grpc        : $prtt/   - XRAY  Vmess Grpc        : $prtt2/g" /root/log-install.txt
iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $prtt -j ACCEPT
iptables -D INPUT -m state --state NEW -m udp -p udp --dport $prtt -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $prtt2 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport $prtt2 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null
netfilter-persistent reload > /dev/null
systemctl restart vmess-grpc.service > /dev/null 2>&1
echo -e "\e[032;1mPort $prtt modified successfully\e[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"

setting-menu