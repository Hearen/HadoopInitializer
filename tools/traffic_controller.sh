#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-14 11:29
# Description : Used to throttle a sustained maximum rate of certain interface;
#-------------------------------------------

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

####################################
#Check the network and try to fix it
####################################
function check_fix_network {
    return_code=`check_network "baidu.com"`
    if [ $return_code -eq 200 ]
    then
        echo "Network available"
    else
        echo "Connection error!"
        echo "Trying to fix the network..."
        service network restart > /dev/null  
        login_network
        return_code=`check_network "baidu.com"`
        if [ $return_code -eq 200 ]
        then
            echo "Network available now."
            return 0
        else
            echo "Failed to fix the connection."
            echo "When you are using ISCAS Network, you might have to run login.sh first, enclosed with this program"
            echo "To login in to access network."
            echo "If you are using other networks, you should try to use browser to login or rewrite the login.sh to login."
            echo "Remember sometimes 'ping works' does not mean you can access network normally and install online packages."
            echo "You have to fix the network by yourself now."
            echo "Leaving the script..."
            return 1
        fi 
    fi
}

#check_fix_network

####################################################
#Ensure the root privelege is granted to the script
####################################################
function check_permission {
    if [ $UID -ne 0 ]
    then
        echo
        echo "Pemission denied!"
        echo "To run this program successfully "
        echo "Try to use root account or sudo command."
        return 1
    else
	return 0
    fi
}

echo "First we need do some checking..."

#Ensure root privilege;
echo
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Permission Granted." 
else 
    echo "Permission Denied!" 
    exit 1
fi

#Ensure the network connection is okay;
echo
check_fix_network
if [ $? -eq 0 ]
then
    echo "Connection Okay!"
else
    echo "Failed to fix the connection."
    echo "Leaving the program..."
    exit 1
fi

read -p "Input the interface: " interface
read -p "The maximum rate [unit: mbps]: " max
tc qdisc del dev $interface root
tc qdisc add dev $interface handle 1: root htb
tc class add dev $interface parent 1: classid 1:1 htb rate "$max"mbps
tputs setaf 1
echo "Make some checking..."
tputs sgr0
tc qdisc show dev $interface && tc class show dev $interface
