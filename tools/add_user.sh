#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-03 11:25
# Description : Add a certain user for a cluster
#-------------------------------------------

#Root privilege required
#Add a new user and enable sudo command for each host in the cluster;
function add_user {
    user_name=$1
    ips_file=$2
    echo $1
    echo $2
    for ip in $(cat $ips_file)
    do
        ip_checker $ip
        if [ $? -gt 0 ]
        then
            echo "Wrong IP, check the $ip in $ips_file"
            return 1
        fi
        echo "Adding user [$user_name] for $ip"
        ssh $ip "useradd $user_name &&  passwd $user_name && usermod -aG wheel $user_name"
        echo "User [$user_name] added to $ip group wheel successfully!"
        echo "Now you can use sudo to run root commands in $ip." #if till now the sudo command is not available, you might check /etc/sudoers and uncomment wheel group;
    done
}

# To directly run this script to add a certain user for a cluster of remotes
# Uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
echo "Root privilege is required to run this script."
check_permission 
if [ $? -gt 0  ] 
then 
    echo "Leaving..."
    exit 1
fi

add_user $USER_NAME $IPS_FILE
