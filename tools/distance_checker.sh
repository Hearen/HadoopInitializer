#!/bin/bash
#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Wed, 2016-05-25 19:16
#Description : Used to check the network distance among hosts;
#####################################################################################

# Utilize command ping to check the network environment
# Among all the hosts - IP address is provided in a file
# 
# ToDo:
# Take advantage of Expect to automate the password-input issue;
function distance_checker {
    ips_file=$1
    count=$2
    for localhost in $(cat $ips_file)
    do
        highlight_str 1 "Source IP address is [$localhost]"
        for ip in $(cat $ips_file)
        do
            if [[ $localhost != $ip ]]
            then
                highlight_str 6 "[$localhost] pinging [$ip]..."
                ssh $localhost "ping -c$count $ip"
            fi
        done
    done
}


# To directly run this script to add a certain user for a cluster of remotes
# Uncomment the following lines;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#source $TOOLS_DIR"/highlighter.sh"
#distance_checker $IPS_FILE 5

