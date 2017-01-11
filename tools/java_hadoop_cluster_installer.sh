#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-05 15:11
# Description : Install jdk and hadoop for all the remotes in the cluster;
#-------------------------------------------

# Copy all the essential jdk and hadoop files to remotes
# And configure related environment variables;
# 
# As long as the working user can be passwordfree ssh-login
# Then it's innecessary to utilize Expect here;
function install_for_all_hosts {
    # Copy jdk and hadoop files, append environment variables for hosts;
    highlight_str 6 "Start to checking java and hadoop installation for other hosts..."
    for ip in $(cat $IPS_FILE)
    do
        highlight_str 6  "Configure java and hadoop for remote [$ip]"
        if [[ "$ip" != "$LOCAL_IP_ADDRESS" ]]
        then
            # Configure java for remote
            highlight_str 6 "Checking java installation in [$ip]"
            remote_directory_checker $USER_NAME $ip $JDK_FILE
            if [ $? -gt 0 ]
            then
                highlight_str 6 "Copy all the essential jdk files to $ip  ..."
                scp -r $JDK_FILE $USER_NAME@$ip:$USER_HOME
            fi

            # Configure hadoop for remote
            highlight_str 6 "Checking hadoop files in [$ip]"
            remote_directory_checker $USER_NAME $ip $HADOOP_FILE
            if [ $? -gt 0 ]
            then
                highlight_str 6 "Copy all the essential hadoop files to $ip ..."
                scp -r $HADOOP_FILE $USER_NAME@$ip:$USER_HOME
            fi
        fi
        highlight_str 6 "Trying to configure environment variables in /etc/profile for $ip"
        $TOOLS_DIR"/append_remote_file.exp" $ENV_CONF_FILE $PASSWORD $ip "/etc/profile"
    done
    copy_hadoop_configuration_files $IPS_FILE # hadoop_remote_configurer.sh
    return 0
}

# To directly run this script to add a certain user for a cluster of remotes
# Uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
install_for_all_hosts 
