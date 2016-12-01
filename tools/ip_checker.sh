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
