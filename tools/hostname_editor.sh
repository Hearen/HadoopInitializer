#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-28 20:38
# Description : Edit the hostnames of the remotes
#-------------------------------------------

# Root privilege required
# Converting all the ips in the etc/ip_addresses file to hostnames
# The first will be hadoop-master while all the rest will 
# Be hadoop-slavex; x ranges from 1 to n-1
# Then update all the hosts accordingly overwriting the /etc/hosts file
# Besides, to further ease the configuring burden, this script will also 
# Automatically update the hadoop configuration file - slaves
function edit_hosts {
    ips_file=$1
    password=$2
    hosts_file=$3
    count=0
    rm -rf $hosts_file 
    for ip in $(cat $ips_file)
    do
        if [ $count -eq 0 ]
        then
            hostname="hadoop-master"
        else
            echo $HADOOP_CONF_SLAVES
            if [ $count -eq 1 ]
            then
                echo "hadoop-slave$count" > "$HADOOP_CONF_SLAVES"
            else
                echo "hadoop-slave$count" >> "$HADOOP_CONF_SLAVES"
            fi
            hostname="hadoop-slave$count"
        fi
        count=$[count+1]
        echo "$ip $hostname" >> $hosts_file
        highlight_substr 2 "Update the hostname of [" "$ip" "] to $hostname"
        $TOOLS_DIR"/edit_remote_hostname.exp" $ip $password $hostname
    done
    echo
    highlight_str 6 "Start to replace /etc/hosts for each host in the cluster..."
    for ip in $(cat $ips_file)
    do 
        highlight_substr 2 "Updating the /etc/hosts for [" "$ip" "]"
        # To modify /etc/profile, root as the user is a must
        $TOOLS_DIR"/copy_local_file.exp" $hosts_file root $password $ip":/etc/hosts"  
    done
}


# To directly run this script to add a certain user for a cluster of remotes
# Uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
echo "Root privilege is required to run this script."
check_permission 
if [ $? -gt 0  ] 
then 
    echo "Leaving..."
    exit 1
fi
edit_hosts $IPS_FILE $PASSWORD $HOSTS_FILE
