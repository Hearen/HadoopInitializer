#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-05 15:11
# Description : Install jdk and hadoop for all the remotes in the cluster;
#-------------------------------------------

# Root privilege required
# Copy all the essential jdk and hadoop files to remotes 
# And configure related environment variables;
#
# ToDo:
# Utilize Expect to automate the password-input issue
function install_for_all_hosts {
    user_name=$1
    env_conf_dir=$2
    ips_file=$3
    # echo "Checking java and hadoop installation in [$LOCAL_IP_ADDRESS]"
    # java_checker $LOCAL_IP_ADDRESS $USER_NAME
    # if [ $? -gt 0 ] || ! [ -d "$HADOOP_FILE" ] || ! [ -d "$JDK_FILE" ]
    # then
        # echo "Java or hadoop installed or configured abnormally!"
        # echo "Please re-check their installation and re-try."
        # return 1
    # fi
    # Copy jdk and hadoop files, append environment variables for hosts;
    highlight_str 6 "Start to checking java and hadoop installation for other hosts..."
    for ip in $(cat $ips_file)
    do
        echo  "[$LOCAL_IP_ADDRESS] connected to [$ip]"
        if [[ "$ip" != "$LOCAL_IP_ADDRESS" ]]
        then
            highlight_str 6 "Checking java installation in [$ip]"
            java_checker $ip $user_name
            if [ $? -gt 0 ]
            then
                echo "Copy all the essential jdk files to $ip  ..."
                ssh $ip "rm -rf $JDK_FILE"
                scp -r $JDK_FILE $ip:/opt/
            fi
            highlight_str 6 "Checking hadoop files in [$ip]"
            remote_directory_checker $ip $user_name $HADOOP_FILE
            if [ $? -gt 0 ]
            then
                highlight_str 6 "Copy all the essential hadoop files to $ip ..."
                ssh $ip "rm -rf $HADOOP_FILE"
                scp -r $HADOOP_FILE $user_name@$ip:/home/$user_name/
            fi
        fi
        highlight_str 6 "Trying to configure environment variables in /etc/profile for $ip"
        echo $env_conf_dir $ip
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
            copy_hadoop_configuration_files $IPS_FILE
            break
        fi
    done
    return 0
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
install_for_all_hosts $USER_NAME $ENV_CONF_FILE $IPS_FILE 
