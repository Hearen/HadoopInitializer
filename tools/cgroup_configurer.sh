#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Mon, 2016-05-30 09:26
#Description : Used to configure cgroup by several configuration files;
#####################################################################################

# Root privilege required
# 1. First check if the essential packages are installed
#    And if not, try to install them automatically;
# 2. Copy the cgroup configuration files to the remote hosts
# 3. And try to start and enable the related services;
# 
# ToDo:
# Utilize Expect to automate the password-input issue
function cgroup_configurer {
    for ip in $(cat $IPS_FILE)
    do
        highlight_str 2 "Start to copy cgroup configuration files to [$ip]"
        scp $CGROUP_CONF_DIR $ip:/etc/
        echo "Start and enable cgconfig and cgred services in [$ip]"
        ssh $ip "systemctl start cgconfig && systemctl enable cgconfig && systemctl start cgred && systemctl enable cgred"
    done
}

# To run this script directly, uncomment the following lines;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#source $TOOLS_DIR"/package_installed_checker.sh"

#echo "Root privilege is required to run this script."
#check_permission 
#if [ $? -gt 0  ] 
#then 
    #echo "Leaving..."
    #exit 1
#fi

#check_package "libcgroup*"
#cgroup_configurer
