#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-01 10:24
# Description : Check the existence of a directory in remote host;
#-------------------------------------------

# Return 0 if the directory exists in the remote host
# Otherwise return 1;
function remote_directory_checker {
    ip=$1
    user_name=$2
    remote_dir=$3
    if (ssh $user_name@$ip "[ -d "$remote_dir"  ]")
    then
        echo "exists!"
        return 0
    else 
        echo "does not exist!"
        return 1
    fi
}

# Uncomment the following lines to directly test the script
#remote_directory_checker "133.133.135.34" "hadoop" "/home/hadoop/hadoop"
#remote_directory_checker "133.133.135.34" "hadoop" "/home/hadoop/hadoop000"
