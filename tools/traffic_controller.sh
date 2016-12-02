#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@gmail.com
# Time        : 2016-06-14 11:29
# Description : Used to throttle a sustained maximum rate of an interface;
#-------------------------------------------

# Throttle a specific interface to a specified speed by command `tc`
function throttle_interface {
    interface=$1
    max_speed=$2
    tc qdisc del dev $interface root
    tc qdisc add dev $interface handle 1: root htb
    tc class add dev $interface parent 1: classid 1:1 htb rate "$max_speed"mbps
    highlighter_str 1 "Make some checking..."
    tc qdisc show dev $interface && tc class show dev $interface
}

# To directly run this script to throttle a certain interface
# Uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
echo "Root privilege is required to run this script."
check_permission 
if [ $? -gt 0  ] 
then 
    echo "Leaving..."
    exit 1
fi
#Ensure the network connection is okay;
check_fix_network
if [ $? -gt 0 ]
then
    echo "Leaving the program..."
    exit 1
fi

read -p "Input the interface you intend to throttle: " interface
highlighter_str 2 "You can utilize `ip a` or `ifconfig` to find out the interfaces"
read -p "The maximum rate [unit: mbps]: " max
