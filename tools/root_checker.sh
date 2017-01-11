#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-28 20:38
# Description : Check the privilege is root or not;
#-------------------------------------------

# Ensure the root privilege is granted
# Return 0 if granted otherwise 1;
function check_permission {
    if [ $UID -ne 0 ]
    then
        echo
        echo "Permission denied!"
        echo "Try to use root account or sudo command."
        return 1
    else
        echo "Root privilege granted!"
        return 0
    fi
}

# Uncomment the following lines to run this script directly;
#check_permission

