#!/bin/bash

#Edited

dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd /root
#System version number
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi

echo -e "[ ${tyblue}NOTES${NC} ] Before we go.. "
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] I need check your headers first.."
sleep 2
echo -e "[ ${green}INFO${NC} ] Checking headers"
sleep 1

secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
screen -r setup
END
chmod 644 /root/.profile

echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aight good ... installation file is ready"
sleep 2
echo -ne "[ ${green}INFO${NC} ] Check  : "

sleep 1

mkdir -p /var/lib/scrz-prem >/dev/null 2>&1
echo "IP=" >> /var/lib/scrz-prem/ipvps.conf

x="ok"
while true $x != "ok"
do
echo -e "[ ${green}INFO${NC} ] Select core : " 
echo -e "[ ${yell}*${NC} ] 1. V2RAY"
echo -e "[ ${yell}*${NC} ] 2. XRAY"
echo " =--------------="
echo -ne "[ ${red}#${NC} ] Choice : "; read x
case "$x" in
   1)
   coreselect="v2ray"
   green "V2RAY Selected"
   sleep 3
   break
   ;;
   2)
   coreselect="xray"
   green "XRAY Selected"
   sleep 3
   break
   ;;
   *)
   echo -e "\n\033[1;31mNot Valid!\033[0m"
   sleep .1
esac
done

if [ -f "/etc/$coreselect/domain" ]; then
echo ""
echo -e "[ ${green}INFO${NC} ] Script Already Installed"
echo -ne "[ ${yell}WARNING${NC} ] Do you want to install again ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
rm setup.sh
sleep 10
exit 0
else
clear
fi
fi

echo ""
wget -q https://raw.githubusercontent.com/farelvpn/std/main/dependencies
chmod +x dependencies 
screen -S depen ./dependencies
rm dependencies


if [ -f "/etc/$coreselect/domain" ]; then
clear
echo ""
domainbefore=`cat /etc/$coreselect/domain`
echo -e "[ ${green}INFO${NC} ] Current domain : $domainbefore"
echo -ne "[ ${yell}WARNING${NC} ] Do you want to change your domain before ? (y/n)? "
read answer
    if [ "$answer" == "${answer#[Yy]}" ] ;then
        echo -ne
        cp /etc/$coreselect/domain /root/scdomain
        cp /etc/$coreselect/domain /root/domain
    else
        clear
        yellow "Change Domain for vmess/vless/trojan dll"
        echo " "
        read -rp "Input ur domain : " -e pp
            if [ -z $pp ]; then
                echo -e "
                Nothing input for domain!
                Then a random domain will be created
                "
                sleep 2
                sub=ctech`</dev/urandom tr -dc a-z0-9 | head -c4`
                echo "peler=${sub}" > /root/scdomain
            else
                echo "peler=$pp" > /root/scdomain
            fi
        wget -q "https://raw.githubusercontent.com/farelvpn/std/main/dll/cf.sh" && chmod +x cf.sh && ./cf.sh
    fi
else
clear
yellow "Add Domain for vmess/vless/trojan dll"
echo " "
read -rp "Input ur domain : " -e pp
    if [ -z $pp ]; then
        echo -e "
        Nothing input for domain!
        Then a random domain will be created
        "
        sleep 2
        sub=ctech`</dev/urandom tr -dc a-z0-9 | head -c4`
        echo "peler=${sub}" > /root/scdomain
    else
        echo "peler=$pp" > /root/scdomain
    fi
wget -q "https://raw.githubusercontent.com/farelvpn/std/main/dll/cf.sh" && chmod +x cf.sh && ./cf.sh
fi

wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/farelvpn/std/main/newmenu.sh" && chmod +x /usr/bin/menu
wget -q "https://raw.githubusercontent.com/farelvpn/std/main/ssh/ssh-vpn.sh" && chmod +x ssh-vpn.sh && screen -S sshvpn ./ssh-vpn.sh
if [ "$coreselect" = "v2ray" ]; then
wget -q "https://raw.githubusercontent.com/farelvpn/std/main/v2ray/ins-vt.sh" && chmod +x ins-vt.sh && screen -S insvt ./ins-vt.sh
elif [ "$coreselect" = "xray" ]; then
wget -q "https://raw.githubusercontent.com/farelvpn/std/main/xray/ins-xray.sh" && chmod +x ins-xray.sh && screen -S insxray ./ins-xray.sh
fi
wget -q "https://raw.githubusercontent.com/farelvpn/std/main/dll/system/set-br.sh" && chmod +x set-br.sh && screen -S sbr ./set-br.sh
#extension
clear
sleep 1
echo -e "[ ${green}INFO${NC} ] Downloading extension !!"
sleep 1
wget -q -O /usr/bin/xtls "https://raw.githubusercontent.com/farelvpn/std/main/xray/xtls.sh" && chmod +x /usr/bin/xtls && xtls && rm -f /usr/bin/xtls
wget -q -O /usr/bin/setting-menu "https://raw.githubusercontent.com/farelvpn/std/main/menu_all/setting-menu.sh" && chmod +x /usr/bin/setting-menu
wget -q -O /usr/bin/autokill-menu "https://raw.githubusercontent.com/farelvpn/std/main/menu_all/autokill-menu.sh" && chmod +x /usr/bin/autokill-menu
wget -q -O /usr/bin/info-menu "https://raw.githubusercontent.com/farelvpn/std/main/menu_all/info-menu.sh" && chmod +x /usr/bin/info-menu
wget -q -O /usr/bin/system-menu "https://raw.githubusercontent.com/farelvpn/std/main/menu_all/system-menu.sh" && chmod +x /usr/bin/system-menu
wget -q -O /usr/bin/trial-menu "https://raw.githubusercontent.com/farelvpn/std/main/menu_all/trial-menu.sh" && chmod +x /usr/bin/trial-menu


wget -q -O /usr/bin/kill-by-user "https://raw.githubusercontent.com/farelvpn/std/main/dll/kill-by-user.sh" && chmod +x /usr/bin/kill-by-user
wget -q -O /usr/bin/kumbang "https://raw.githubusercontent.com/farelvpn/std/main/dll/kumbang.sh" && chmod +x /usr/bin/kumbang
wget -q -O /usr/bin/importantfile "https://raw.githubusercontent.com/farelvpn/std/main/dll/toolkit.sh" && chmod +x /usr/bin/importantfile
wget -q -O /usr/bin/status "https://raw.githubusercontent.com/farelvpn/std/main/dll/status.sh" && chmod +x /usr/bin/status
wget -q -O /usr/bin/autoreboot "https://raw.githubusercontent.com/farelvpn/std/main/dll/autoreboot.sh" && chmod +x /usr/bin/autoreboot
wget -q -O /usr/bin/limit-speed "https://raw.githubusercontent.com/farelvpn/std/main/dll/limit-speed.sh" && chmod +x /usr/bin/limit-speed
wget -q -O /usr/bin/add-host "https://raw.githubusercontent.com/farelvpn/std/main/dll/add-host.sh" && chmod +x /usr/bin/add-host
wget -q -O /usr/bin/akill-ws "https://raw.githubusercontent.com/farelvpn/std/main/dll/akill-ws.sh" && chmod +x /usr/bin/akill-ws
wget -q -O /usr/bin/autokill-ws "https://raw.githubusercontent.com/farelvpn/std/main/dll/autokill-ws.sh" && chmod +x /usr/bin/autokill-ws
wget -q -O /usr/bin/restart-service "https://raw.githubusercontent.com/farelvpn/std/main/dll/restart-service.sh" && chmod +x /usr/bin/restart-service
 
wget -q -O /usr/bin/installbot "https://raw.githubusercontent.com/farelvpn/std/main/bot_panel/installer.sh" && chmod +x /usr/bin/installbot
wget -q -O /usr/bin/bbt "https://raw.githubusercontent.com/farelvpn/std/main/bot_panel/bbt.sh" && chmod +x /usr/bin/bbt

sleep 2
echo -e "[ ${green}INFO${NC} ] Installing Successfully!!"
sleep 1
echo -e "[ ${green}INFO${NC} ] Dont forget to reboot later"
#=======[ end ] ======
wget -q -O /usr/bin/xp https://raw.githubusercontent.com/farelvpn/std/main/dll/xp.sh && chmod +x /usr/bin/xp
wget -q -O /usr/bin/info https://raw.githubusercontent.com/farelvpn/std/main/dll/info.sh && chmod +x /usr/bin/info

#set time zone
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

wget -q -O /usr/bin/.ascii-home "https://raw.githubusercontent.com/farelvpn/std/main/resources/ascii-home"
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
importantfile
menu
END
chmod 644 /root/.profile

if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi
history -c
serverV=$( curl -sS https://raw.githubusercontent.com/apih46/access/main/versi  )
echo $serverV > /opt/.ver
aureb=$(cat /home/re_otm)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
curl -sS ifconfig.me > /etc/myipvps
echo " "
echo "====================-[ pompom Premium ]-===================="
echo ""
echo "------------------------------------------------------------"
echo ""
echo ""
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - SSH Websocket           : 2082 [OFF]" | tee -a log-install.txt
echo "   - SSH SSL Websocket       : 222" | tee -a log-install.txt
echo "   - OHP SSH                 : 6967" | tee -a log-install.txt
echo "   - OHP DBear               : 6968" | tee -a log-install.txt
echo "   - OHP OpenVPN             : 6969" | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 442"  | tee -a log-install.txt
echo "   - Stunnel4                : 447, 777" | tee -a log-install.txt
echo "   - Dropbear                : 109, 143" | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080" | tee -a log-install.txt
echo "   - Badvpn                  : 7100-7900" | tee -a log-install.txt
echo "   - Nginx                   : 81" | tee -a log-install.txt
echo "   - VLess TCP XTLS          : 443" | tee -a log-install.txt
if [ "$coreselect" = "v2ray" ]; then
echo "   - V2RAY Vmess GRPC        : 2099" | tee -a log-install.txt
echo "   - V2RAY Vmess TLS         : 435" | tee -a log-install.txt
echo "   - V2RAY Vmess None TLS    : 95" | tee -a log-install.txt
echo "   - V2RAY Vless TLS         : 445" | tee -a log-install.txt
echo "   - V2RAY Vless None TLS    : 80" | tee -a log-install.txt
elif [ "$coreselect" = "xray" ]; then
echo "   - XRAY  Vmess TLS         : 443" | tee -a log-install.txt
echo "   - XRAY  Vmess None TLS    : 95" | tee -a log-install.txt
echo "   - XRAY  Vless TLS         : 443" | tee -a log-install.txt
echo "   - XRAY  Vless None TLS    : 80" | tee -a log-install.txt
echo "   - XRAY  Vmess Grpc        : 999" | tee -a log-install.txt
echo "   - XRAY  Vless Grpc        : 880" | tee -a log-install.txt
echo "   - XRAY  Trojan Grpc       : 653" | tee -a log-install.txt
fi

echo "   - Trojan                  : 8443" | tee -a log-install.txt
echo "   - Trojan Go               : 2096" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Kuala_Lumpur (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On           : $aureb:00 $gg GMT +8" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - AutoKill Multi Login User" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Fully automatic script" | tee -a log-install.txt
echo "   - VPS settings" | tee -a log-install.txt
echo "   - Admin Control" | tee -a log-install.txt
echo "   - Change port" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo ""
echo ""
echo "------------------------------------------------------------"
echo ""
echo "===============-[ Script Created By pompom ]-==============="
echo -e ""
echo ""
echo "" | tee -a log-install.txt
systemctl restart ohp-ssh > /dev/null 2>&1
systemctl restart ohp-db > /dev/null 2>&1
systemctl restart ohp-opn > /dev/null 2>&1
rm /root/cf.sh >/dev/null 2>&1
rm /root/setup.sh >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
echo -e "
"
systemctl restart ssrmu > /dev/null 2>&1
read -n 1 -s -r -p "Press any key to reboot"
reboot
