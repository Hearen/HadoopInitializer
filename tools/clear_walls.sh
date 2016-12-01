#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-03 11:25
# Description : Shut down and disable firewall as well as selinux for a cluster of hosts
#-------------------------------------------

#Root privilege required
#Used to shut down selinux and firewall and disable them completely and in the end reboot the remotes;
function clear_the_walls {
    highlight_str 1 "Trying to disable selinux and shut down firewall for all the hosts in the cluster..."
    highlight_substr 1 "Remember we will have to reboot the host to make it take effect immediately, so please wait until it's done " "rebooting" "."
    ips_file=$1
    for ip in $(cat $ips_file)
    do
	if [[ -z $(echo $ip | grep $LOCAL_IP_ADDRESS) ]]
        then
            highlight_str 6 "Copy selinux configuration file to [$ip]"
            cat etc/selinux.config | ssh $ip "cat > /etc/selinux/config"
            #scp etc/selinux.config $ip:/etc/selinux/config
            highlight_str 6 "Trying to stop and disable the firewall in [$ip], and restart it."
            ssh $ip "systemctl stop firewalld ; systemctl disable firewalld ; reboot"
            # in case there is no such service using ; instead of &&
        fi
    done
    ip=$LOCAL_IP_ADDRESS
    highlight_str 6 "Copy selinux configuration file to [$ip]"
    cat etc/selinux.config | ssh $ip "cat > /etc/selinux/config"
    highlight_str 6 "Trying to stop and disable the firewall in [$ip], and " "reboot" " it."
    ssh $ip "systemctl stop firewalld ; systemctl disable firewalld ; reboot"
}

# To run this script to clear the walls, uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
source $TOOLS_DIR"/checker.sh"
source $TOOLS_DIR"/highlight_substr.sh"

echo "root privilege is required to run this script."
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Permission Granted." 
else 
    echo "Leaving..."
    exit 1
fi

#echo "Start to clear up the walls..." 

clear_the_walls $IPS_FILE 
