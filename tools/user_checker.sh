#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-29 09:27
# Description : Checking whether the current working user is the user provided by user_name;
#-------------------------------------------

# Check whether the current working user
# Is the user_name or not;
# Return 0 as true otherwise 1 as false;
function user_checker {
    user_name=$1
    if [ "$user_name" != `whoami` ]
    then
        return 1
    else
        return 0
    fi
}

#echo "user_checker loaded!"
# To directly execute the script, uncomment the following lines;
#user_checker $1
#if [ $? -eq 0 ]
#then
    #echo "Match!"
#else
    #echo "Wrong user!"
#fi
