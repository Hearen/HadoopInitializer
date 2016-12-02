#!/bin/bash
##########################
# Author      : LHearen
# E-mail      : LHearen@gmail.com
# Time        : Thu, 2016-12-01 10:50
# Description : Check the network connection and try to fix in ISCAS;
##########################

# Using a given test site to check the network 
# And return Http code - 200->okay
function check_network {
   test_site=$1
   timeout_max=2    # seconds
   return_code=`curl -o /dev/null/ --connect-timeout $timeout_max -s -w %{http_code} $test_site`
   echo $return_code
}

# Log in to access external network in ISCAS
function login_network {
    userName=${1:-"luosonglei14"}
    password=${2:-"111111"}
    max_try=${3:-3}
    count=1
    while [ "$count" -le "$max_try" ]
    do
        return_code=$(check_network "baidu.com")
        if [ $return_code -eq 200 ]
        then
            tput setaf 2
            echo "Network available"
            tput sgr0
            return 0
        else
            tput setaf 1
            echo "Connection error"
            tput sgr0
            echo "Trying to fix it..." ": try $count"
            curl -d "username=$userName&password=$password&pwd=$password&secret=true" http://133.133.133.150/webAuth/ 1>/dev/null 2>/dev/null
            sleep 1
        fi
        count=$[count+1]
    done
    return 1
}

# This log-in script is merely used for ISCAS log-in;
# To directly use this script as a log-in script, 
# Just uncomment the following lines;
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
#login_network $userName $password

