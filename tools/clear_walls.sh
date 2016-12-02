#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-03 11:25
# Description : Shut down and disable firewall as well as selinux for a cluster of hosts
#-------------------------------------------

# Root privilege required
# Used to shut down selinux and firewall and disable 
# Them completely and in the end reboot the remotes;
#
# ToDo:
# Utilize Expect to automate the password-input issue
function clear_the_wall {
    ip="$1"
    highlight_str 6 "Copy selinux configuration file to [$ip]"
    cat $ETC_DIR"/selinux.config" | ssh $ip "cat > /etc/selinux/config"
    highlight_str 6 "Trying to stop and disable the firewall in [$ip], and restart it."
    # in case there is no such service using ; instead of &&
    ssh $ip "systemctl stop firewalld ; systemctl disable firewalld ; reboot"
}


function clear_the_walls {
    highlight_str 1 "Trying to disable selinux and shut down firewall for all the hosts in the cluster..."
    highlight_substr 1 "Remember we will have to reboot the host to make it take effect immediately, so please wait until it's done " "rebooting" "."
    for ip in $(cat $IPS_FILE)
    do
        # ensure the local host will be handled last due to reboot
        if [[ -z $(echo $ip | grep $LOCAL_IP_ADDRESS) ]] 
        then
            clear_the_wall $ip
        fi
    done
    clear_the_wall $LOCAL_IP_ADDRESS
}

# To run this script to clear the walls, uncomment the following lines;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#echo "Root privilege is required to run this script."
#check_permission 
#if [ $? -gt 0  ] 
#then 
    #echo "Leaving..."
    #exit 1
#fi

#echo "Start to clear up the walls..." 
#clear_the_walls 
