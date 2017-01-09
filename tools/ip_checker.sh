#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-30 16:25
# Description : Check the validity of the IP
#-------------------------------------------

# Return 0 if the IP is valid otherwise 1
# The checking mechanism:
# 1. Format will be *.*.*.*;
# 2. Each number is less than 256;
# 3. Asterisk `*` is allowed for wild-card matching;
# The IP may not be valid in the network.
function ip_checker {
    local ip=$1
    result=`echo $ip | gawk --re-interval '/^([0-9]{1,3}|\*)\.([0-9]{1,3}|\*)\.([0-9]{1,3}|\*)\.([0-9]{1,3}|\*)$/'`
    #echo $result
    if [ -z "$result" ]
    then
        return 1
    fi
    tmp=`echo $ip | sed "s/\./ /g; s/\*/a/g"` # replace dot `.` by whitespace and asterisk by letter `a`
    #echo ${tmp[*]}
    for a in $tmp # an array separated by whitespace
    do
        #echo $a
        if [ $a != "a" ] && [ $a -gt 255 ] 
        then
            return 1
        fi
    done
    return 0
}

# Return 1 if a IP address provided is not valid otherwise 0
# Used to ensure all the IP addresses provided is valid before further action
function cluster_ip_checker {
    for ip in $(cat $IPS_FILE)
    do
        highlight_str 2 "$ip"
        ip_checker $ip
        if [ $? -gt 0 ]
        then
            highlight_str 1 "$ip is not valid!"
            return 1
        fi
    done
    tput bold
    highlight_str 2 "All IPs in the cluster are valid!"
    return 0
}

# To directly run this script to check the validity of the IP addresses
# Uncomment the following lines;

#while true
#do
    #read -p "Input the ip to test: " ip
    #ip_checker $ip
    #if [ $? -eq 0 ]
    #then
        #echo "Correct!"
    #else
        #echo "Wrong!"
    #fi
#done

# To test the validity of the cluster IPs
# Uncomment the following lines instead

#BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
#ETC_DIR=$BASE_DIR"/etc"
#source $ETC_DIR"/args.conf"
#source $TOOLS_DIR"/highlighter.sh"
#cluster_ip_checker
#if [ $? -eq 0 ]
#then
    #highlight_str 2 "All are valid!"
#fi
