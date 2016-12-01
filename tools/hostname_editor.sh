#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-28 20:38
# Description : Edit the hostnames of the remotes
#-------------------------------------------

# Root privilege required
# Converting all the ips in the etc/ip_addresses file to hostnames
# The first will be hadoop-master while all the rest will be hadoop-slavex; x ranges from 1 to n-1
# Then update all the hosts accordingly overwriting the /etc/hosts file
# Besides, to further ease the configuring burden, this script will also 
# Automatically update the hadoop configuration file - slaves
function edit_hosts {
    ips_file=$1
    hosts_file=$2
    count=0
    rm -rf $hosts_file 
    for ip in $(cat $ips_file)
    do
        ip_checker $ip
        if [ $? -gt 0 ]
        then
            echo "Wrong ip, check the [$ip] in $ips_file";
            return 1
        fi
        if [ $count -eq 0 ]
        then
            hostname="hadoop-master"
        else
            if [ $count -eq 1 ]
            then
                echo "hadoop-slave$count" > $HADOOP_CONF_SLAVES
            else
                echo "hadoop-slave$count" >> $HADOOP_CONF_SLAVES
            fi
            hostname="hadoop-slave$count"
        fi
        count=$[count+1]
        echo "$ip $hostname" >> $hosts_file
        echo "Update the hostname of [$ip] to $hostname"
        ssh $ip hostnamectl set-hostname $hostname --static
    done
    echo
    tput setaf 6
    echo "Start to replace /etc/hosts for each host in the cluster..."
    tput sgr0
    for ip in $(cat $ips_file)
    do 
        echo "Updating the /etc/hosts for [$ip"]
        cat $hosts_file | ssh $ip "cat > /etc/hosts"
    done
}


# To execute the program directly, uncomment the following lines
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
source $TOOLS_DIR"/highlighter.sh"
source $TOOLS_DIR"/root_checker.sh"
echo "Essential parameters and scripts are loaded!"

echo "root privilege is required to run this script."
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Permission Granted." 
else 
    echo "Leaving..."
    exit 1
fi

# To directly execute the script, uncomment the following line;
#edit_hosts $IPS_FILE $HOSTS_FILE
