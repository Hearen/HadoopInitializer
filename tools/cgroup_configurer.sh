#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Mon, 2016-05-30 09:26
#Description : Used to configure cgroup by several configuration files;
#####################################################################################

cd ..

. checker.sh
. initializer.sh

CG_FILE="etc/cg*"

#Root required
function cgroup_configurer {
    ips_file=$1
    echo $ips_file
    for ip in $(cat $ips_file)
    do
        echo "Start to copy cgroup configuration files to [$ip]"
        scp $CG_FILE $ip:/etc/
        echo "Start and enable cgconfig and cgred services in [$ip]"
        ssh $ip "systemctl start cgconfig && systemctl enable cgconfig && systemctl start cgred && systemctl enable cgred"
    done
}

echo "root privilege is required to run this script."
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Permission Granted." 
else 
    echo "Leaving..."
    exit 1
fi
check_package "libcgroup*"
cgroup_configurer $IPS_FILE
