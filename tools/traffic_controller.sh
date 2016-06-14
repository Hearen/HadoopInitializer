#!/bin/sh
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-14 11:29
# Description : Used to throttle a sustained maximum rate of certain interface;
#-------------------------------------------

cd ..
. checker.sh

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
tc class add dev eth0 parent 1: classid 1:1 htb rate "$max"mbps
echo "Make some checking..."
tc qdisc show dev $interface
tc class show dev $interface
