#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-29 09:27
# Description : Checking the current user and ensure it's not in root mode;
#-------------------------------------------

# If the current user has the same name and 
# Does not su to the root -- root is excluded
# Return 0 as true otherwise 1 as false;
function user_checker {
    user_name=$1
    if [ "$user_name" != `echo "$USER"` ] || [ `id -u` -eq 0 ] 
    then
        return 1
    else
        return 0
    fi
}

# To directly execute the script, uncomment the following lines;
user_checker $1
if [ $? -eq 0 ]
then
    echo "Match!"
else
    echo "Wrong user!"
fi
