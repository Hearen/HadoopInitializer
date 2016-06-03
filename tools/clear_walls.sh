#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-03 11:25
# Description : Shut down and disable firewall as well as selinux for a cluster of hosts
#-------------------------------------------

IPS_FILE="../etc/ip_addresses"
ENV_CONF_FILE="../etc/env.conf"

. ../initializer.sh

echo "root privilege is required to run this script."
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Permission Granted." 
else 
    echo "Leaving..."
    exit 1
fi
clear_the_walls $IPS_FILE

