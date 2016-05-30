#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Mon, 2016-05-30 09:26
#Description : Used to configure cgroup by several configuration files;
#####################################################################################

#Root required
function cgroup_configurer {
    ips_file=$1
    for ip in $(cat $ips_file)
    do
        echo "Start to copy cgroup configuration files to [$ip]"
        scp etc/cg* $ip:/etc/
        echo "Start and enable cgconfig and cgred services in [$ip]"
        ssh $ip "systemctl start cgconfig && systemctl enable cgconfig && systemctl start cgred && systemctl enable cgred"
    done
}

cgroup_configurer "etc/ip_addresses"
