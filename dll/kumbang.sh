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
bugdigi=/root/.ctech/.kumbang/digi
bugumo=/root/.ctech/.kumbang/umobile
bugmaxis=/root/.ctech/.kumbang/maxis
bugunifi=/root/.ctech/.kumbang/unifi
bugyodoo=/root/.ctech/.kumbang/yodoo
bugcelcom=/root/.ctech/.kumbang/celcom
installed=/root/.ctech/.kumbang/install
done=$(cat $installed | grep -w "done" | wc -l)
if [[ ${done} == '1' ]]; then
    echo -ne "BUG DIGI : "
    read bug_digi
    echo "$bug_digi" >$bugdigi
    echo -ne "BUG UMOBILE : "
    read bug_digi
    echo "$bug_digi" >$bugumo
    echo -ne "BUG MAXIS : "
    read bug_digi
    echo "$bug_digi" >$bugmaxis
    echo -ne "BUG UNIFI : "
    read bug_digi
    echo "$bug_digi" >$bugunifi
    echo -ne "BUG YODOO : "
    read bug_digi
    echo "$bug_digi" >$bugyodoo
    echo -ne "BUG CELCOM : "
    read bug_digi
    echo "$bug_digi" >$bugcelcom

else
mkdir /root/.ctech
mkdir /root/.ctech/.kumbang
echo 'ctechdidik.me' >$bugdigi
echo 'ctechdidik.me' >$bugumo
echo 'ctechdidik.me' >$bugmaxis
echo 'ctechdidik.me' >$bugunifi
echo 'ctechdidik.me' >$bugyodoo
echo 'ctechdidik.me' >$bugcelcom
echo 'done' >$installed
clear
kumbang
fi

read -n 1 -s -r -p "Press any key to back on menu"
menu