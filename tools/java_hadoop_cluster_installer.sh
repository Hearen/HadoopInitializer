#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-05 15:11
# Description : Install jdk and hadoop for all the remotes in the cluster;
#-------------------------------------------

# Root privilege required
# Copy all the essential jdk and hadoop files to remotes 
# And configure related environment variables;
function install_for_all_hosts {
    echo "Checking java and hadoop installation in [$LOCAL_IP_ADDRESS]"
    java_checker $LOCAL_IP_ADDRESS $USER_NAME
    if [ $? -gt 0 ] || ! [ -d "$HADOOP_FILE" ] || ! [ -d "$JDK_FILE" ]
    then
        echo "Java or hadoop installed or configured abnormally!"
        echo "Please re-check their installation and re-try."
        return 1
    fi
    #Copy jdk and hadoop files, append environment variables for hosts;
    tput setaf 6
    echo
    echo
    echo "Start to checking java and hadoop installation for other hosts..."
    tput sgr0
    for ip in $(cat $ips_file)
    do
        echo  "[$LOCAL_IP_ADDRESS] connected to [$ip]"
        if [[ -z $(echo $ip | grep $LOCAL_IP_ADDRESS) ]]
        then
            tput setaf 6
            echo "Checking java installation in [$ip]"
            java_checker $ip $user_name
            if [ $? -gt 0 ]
            then
                echo "Copy all the essential jdk files to $ip  ..."
                tput sgr0
                ssh $ip "rm -rf $JDK_FILE"
                scp -r $JDK_FILE $ip:/opt/
            fi
            tput setaf 6
            echo "Checking hadoop files in [$ip]"
            tput sgr0
            remote_directory_checker $ip $user_name $HADOOP_FILE
            if [ $? -gt 0 ]
            then
                tput setaf 6
                echo "Copy all the essential hadoop files to $ip ..."
                tput sgr0
                ssh $ip "rm -rf $HADOOP_FILE"
                scp -r $HADOOP_FILE $user_name@$ip:/home/$user_name/
            fi
        fi
        tput setaf 6
        echo "Trying to configure environment variables in /etc/profile for $ip"
        tput sgr0
        cat $env_conf_dir | ssh $ip "cat >> /etc/profile" 
    done
    echo "You must have configured the *xml files properly according to the cluster."
    while [ 1 ]
    do
        read -p "If not, you need to configure it now, input [ 1|y|Y ] to quit to configure it right now: " flag
        echo
        if [ "$flag" == "1" ] || [ "$flag" == "y" ] || [ "$flag" == "Y" ]
        then
            return 1
        else
            copy_hadoop_configuration_files $ips_file
            break
        fi
    done
    return 0
}

#install_for_all_hosts $USER_NAME $ENV_CONF_FILE $IPS_FILE 
