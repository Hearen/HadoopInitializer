#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-05-05 11:14
#Description : Initialize and update the default parameters;
#####################################################################################

# LOCAL_IP_ADDRESS is retrieved from hostname -i which is ambiguous
# To make it specific and accurate, suppose LOCAL_IP_ADDRESS is also 
# Recorded in the IPS_FILE, by this double checking, it can be specified;
function update_local_IP {
    for ip in $(cat $IPS_FILE)
    do
        if [[ $LOCAL_IP_ADDRESS =~ "$ip" ]] # check substring;
        then
            LOCAL_IP_ADDRESS=$ip
        fi
    done
    echo "$LOCAL_IP_ADDRESS updated!"
}

#update_local_IP

#Used to update the env.conf of the program according to the user
function update_env {
    echo "Updating $ENV_CONF_FILE"
    echo "#Created: $(date)" > $ENV_CONF_FILE
    echo "#configure jdk environment" >> $ENV_CONF_FILE
    echo "export JAVA_HOME=/opt/jdk1.8.0_77" >> $ENV_CONF_FILE
    echo "export JRE_HOME=/opt/jdk1.8.0_77/jre" >> $ENV_CONF_FILE
    echo "export CLASSPATH=.:\$CLASSPATH:\$JAVA_HOME/lib:\$JRE_HOME/lib" >> $ENV_CONF_FILE
    echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin" >> $ENV_CONF_FILE

    echo >> $ENV_CONF_FILE
    echo "#configure hadoop environment" >> $ENV_CONF_FILE
    echo "export HADOOP_HOME=/home/$USER_NAME/hadoop" >> $ENV_CONF_FILE
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> $ENV_CONF_FILE
    echo "export HADOOP_HOME_WARN_SUPPRESS=1" >> $ENV_CONF_FILE
    echo "export CLASSPATH=\$CLASSPATH:\$HADOOP_HOME/share/hadoop/tools/lib/hadoop-core-1.2.1.jar" >> $ENV_CONF_FILE
    echo "$ENV_CONF_FILE updated!"
}

#update_env


#Root privilege required
#Copy all the essential jdk and hadoop files to remotes and configure its environment variables;
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

#Last step testing the hadoop installation
function test_hadoop {
    user_name=$1
    if [ $user_name != `echo "$USER"` ] || [ `id -u` -eq 0 ] #ensure the current user is the user specified by parameter echo $USER is not enough we need id -u to filter further;
    then 
        echo "The current user should be the working user [$USER_NAME]."
        echo -n "You can use"
        tput setaf 4 
        echo -n " su $USER_NAME "
        tput sgr0
        echo "to achieve this and then re-try."
        return 1
    fi
    tput setaf 6
    echo "Trying to start the hadoop..."
    tput sgr0
    start-all.sh
    tput setaf 6
    echo "Checking the service..."
    jps
    tput sgr0
}

#test_hadoop $USER_NAME
