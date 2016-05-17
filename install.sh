#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Sun, 2016-05-08 09:48
#Description : Used to configure hadoop cluster automatically.
#####################################################################################

. ./checker.sh
. ./initializer.sh

clear
tput setaf 1
echo 
echo
display_center "##    Welcome to Hearen's HadoopInitializer    ##"
tput setaf 4
echo
echo
echo "Via this program you can accomplish the following operations automatically:"
echo "1. check the permission of the current role;"
echo "2. check the network and try to fix it if not available;"
echo "3. add working user, set its password and add it to sudoers for later sudo command;"
echo "4. via a file containing all the IP addresses of the hosts to change the hostnames and then update /etc/hosts for all hosts;"
echo "5. via a file containing all the IP addresses of the hosts to enable login via ssh without password among hosts in the cluster;"
echo "6. download jdk 1.8 and configure java, javac and jre locally;"
echo "7. download hadoop 2.7 and install it locally;"
echo "8. via IP addresses of the hosts to configure and activate the newly java and hadoop environment variables;"
echo "9. via IP addresses of the hosts to update the xml configuration files in hadoop for each host of the cluster;"
echo "10. start hadoop in master node and check its status in each node in the cluster;"
echo 
echo 
tput sgr0

echo "First time to run this program press [0]"
echo "After suing to 'USER_NAME' press [1]"

while [ 1 ]
do
    read -n1 -p "What's your choice: " choice
    case $choice in
    0)
        echo
        echo "First we need do some checking..."

        #Ensure root privilege;
        echo
        check_permission 
        if [ $? -eq 0  ] 
        then 
            echo "Root Permission Granted." 
        else 
            echo "Permission denied!" 
            echo "Make sure you are running this program in root or sudo command." 
            echo "Leaving the program..."
            return 1
        fi

        #Ensure the network connection is okay;
        echo
        check_fix_network
        if [ $? -eq 0 ]
        then
            echo "Connection Okay!"
        else
            echo "Failed to fix the connection."
            echo "Leaving the program..."
            return 1
        fi

        #Ensure essential packages are installed - ssh and scp
        echo
        check_essential_packages
        if [ $? -gt 0 ]
        then 
            echo "Leaving the program..."
        fi

        #Add the user for each host and meantime enable sudo command;
        echo
        tput setaf 6
        echo "Let's now add a user for each host in the cluster for later use."
        tput sgr0
        add_user $USER_NAME $IPS_FILE
        if [ $? -gt 0 ]
        then 
            echo "Failed to add user!"
            echo "Leaving the program..."
            return 1
        fi

        #Update the hostnames and synchronize the /etc/hosts among hosts;
        tput setaf 6
        echo
        echo "Let's now set the hostname for each host and synchronise the /etc/hosts file among them."
        echo "It's time to edit hosts for all the hosts in the hadoop cluster."
        tput sgr0
        edit_hosts $IPS_FILE $HOSTS_FILE
        if [ $? -gt 0 ]
        then 
            echo "Failed to edit hostnames!"
            echo "Leaving the program..."
            return 1
        fi

       #Download jdk1.8 and configure it locally;
        tput setaf 6
        echo "Let's start to download and install jdk1.8 locally..."
        tput sgr0
        install_jdk_local #even this failed, it's okay to move on;

        #Download hadoop2.7 and configure it locally;
        tput setaf 6
        echo "Let's just download and install hadloop locally..."
        tput sgr0
        install_hadoop #even this failed, it's okay to move on;


        #After local installation and configuration
        #Install and configure java and hadoop globally in the cluster;
        tput setaf 6
        echo "It's time to install and configure jdk1.8 and hadoop2.7 for all hosts in the cluster..."
        tput sgr0
        configure_environment_variables $USER_NAME $ENV_CONF_FILE $IPS_FILE 
        break
        ;;

    1)
        #Ensure ssh-login without password among hosts in the cluster;
        tput setaf 6
        echo
        echo "Let's enable ssh-login without password among hosts."
        tput sgr0
        enable_ssh_without_pwd $USER_NAME $IPS_FILE
        break
        ;;
    *)
        echo
        echo "Input error!"
        echo "0 for the first time"
        echo "1 for the user '$USER_NAME'"
        ;;
    esac
done
