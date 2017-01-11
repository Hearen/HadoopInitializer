#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-05 15:11
# Description : Re-code the install part after a whole refactor;
#-------------------------------------------

BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
source $BASE_DIR"/tester.sh"
loadAll;
clear
tput setaf 1
echo 
echo
display_center "##    Welcome to Hearen's HadoopInitializer    ##"
tput setaf 6
echo
echo
echo "Via this program you can accomplish the following operations automatically:"
echo "#. Add a new working user, set password and enable sudo command;"
echo "#. Change the hostnames and update /etc/hosts for all hosts;"
echo "#. Achieve password-free ssh login among hosts in the cluster for both the working user and root;"
echo "#. Install jdk 1.8 and configure java, javac and jre locally and remotely;"
echo "#. Install and configure hadoop-*.*.*;"
echo 
echo 
tput sgr0

highlight_substr 1 "Configure java and hadoop locally, requiring" " root " "privilege [1]."
highlight_substr 1 "Configure java and hadoop for the remotes requiring working user" " $USER_NAME " "press [2]"
echo "Press [q|Q] to exit."

while [ 1 ]
do
    read -n1 -p "What's your choice: " choice
    case $choice in
    1) # First run - checking permission, network and essential packages
       # Add a new user and modify the hostnames and hosts
       # Install jdk and hadoop locally and then for all remotes
        echo
        echo "First we need to do some checking..."

        # Ensure root privilege;
        echo
        user_checker "root"
        if [ $? -gt 0  ] 
        then 
            highlight_str 1 "Root privilege is required to continue, try to su to the root and re-try."
            echo
            exit 1
        fi

        # Ensure the network connection is okay;
        echo
        check_fix_network
        if [ $? -gt 0 ]
        then
            exit 1
        fi

        # Ensure essential packages are installed - ssh and scp
        echo
        check_essential_packages
        if [ $? -gt 0 ]
        then 
            exit 1
        fi

        # Ensure all the IPs in the cluster are valid
        cluster_ip_checker 
        if [ $? -gt 0 ]
        then
            exit 1
        fi

        # Add the user for each host and meantime enable sudo command;
        echo
        highlight_str 6 "Let's now add a user for each host in the cluster for later use."
        add_user $USER_NAME $IPS_FILE

        # Update the hostnames and synchronize the /etc/hosts among hosts;
        highlight_str 6 "Let's now set the hostname for each host and synchronise the /etc/hosts file among them."
        edit_hosts $IPS_FILE $PASSWORD $HOSTS_FILE

        # Download jdk1.8 and configure it locally;
        highlight_str 6 "Let's start to download and install jdk1.8 locally..."
        install_jdk_local 
        if [ $? -gt 0 ]
        then
            echo "Failed to install java, please re-try later."
            exit 1
        fi

        # Download hadoop2.7 and configure it locally;
        highlight_str 6 "Let's just download and install hadloop locally..."
        install_hadoop_local 
        if [ $? -gt 0 ]
        then
            echo "Failed to install hadoop, please re-try later."
            exit 1
        fi

        exit 0
        ;;

    2) # Configure for the remotes;
        #
        user_checker $USER_NAME
        if [ $? -gt 0 ]
        then
            highlight_substr "Not the working user " "$USER_NAME" ", please su $USER_NAME and re-try"
            exit 1
        fi
        # 
        highlight_substr 6 "Let's enable" " $USER_NAME" " ssh-login without password among hosts."
        enable_ssh_without_pwd $USER_NAME $PASSWORD $IPS_FILE

        # After local installation and configuration
        # Install and configure java and hadoop globally in the cluster;
        highlight_str 6 "It's time to install and configure jdk1.8 and hadoop2.7 for all hosts in the cluster..."
        echo $USER_NAME $ENV_CONF_FILE $IPS_FILE 
        install_for_all_hosts $USER_NAME $ENV_CONF_FILE $IPS_FILE 

        # 
        highlight_str 4 "Let's test the installation"
        test_hadoop $USER_NAME
        exit 0
        ;;
    q)
        echo
        echo "Leaving the program.."
        exit 0
        ;;
    Q)
        echo
        echo "Leaving the program.."
        exit 0
        ;;
    *)
        echo
        echo "Input error!"
        echo "First time to run this program press [0]"
        echo "After reboot to disable firewall and selinux, now press [1] to install."
        echo "Start copy hadoop XML configuration files for hadoop cluster press [2]"
        echo "Run a simple test in working user '$USER_NAME' press [3]"
        echo "Press [q|Q] to exit."
        ;;
    esac
done
