#!/bin/bash
##########################
# Author: LHearen 
# E-mail: LHearen@126.com 
##########################

#Using a given test site to check the network and return
#Http code 200 - okay
function check_network {
   test_site=$1
   timeout_max=2    #seconds before time out
   return_code=`curl -o /dev/null/ --connect-timeout $timeout_max -s -w %{http_code} $test_site`
   echo $return_code
}

#Log in to access external network in ISCAS
function login_network {
    userName=${1:-"luosonglei14"}
    password=${2:-"111111"}
    while [ 1 ]
    do
        return_code=$(check_network "baidu.com")
        if [ $return_code -eq 200 ]
        then
            tput setaf 2
            echo "Network available"
            tput sgr0
            break
        else
            echo "Connection error"
            echo "Trying to fix it..."
            curl -d "username=$userName&password=$password&pwd=$password&secret=true" http://133.133.133.150/webAuth/ 1>/dev/null 2>/dev/null
            sleep 1
        fi
    done
}

#clear
#echo "Using a fixed account to login - simulating browser login process."
#tput setaf 6
#echo "[Usage: UserName[default: luosonglei14], Password[default: 111111]]"
#tput sgr0
#read -p "UserName:" userName
#tput setaf 6
#echo "Press Enter to use default password 111111"
#tput sgr0
#read -p "Password:" password
login_network $userName $password
