#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Sun, 2016-05-08 09:48
#Description : Used to configure hadoop cluster automatically.
#####################################################################################

. ./checker.sh
. ./initializer.sh

user_name="" #this name will be used to communicate among hosts in the cluster;
ip_dir="" #this file contains all the ips in the cluster to automatic configuration;

clear
echo "#####Welcome to Hearen's HadoopInitializer!#####"
echo "First we need do some checking..."

#Ensure root privilege;
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
check_essential_packages
if [ $? -gt 0 ]
then 
    echo "Leaving the program..."
fi

echo "Let's now add a user for each host in the cluster for later use."
read -p "Input the user name: " user_name 
read -p "Input the ip file: " ip_dir

#Add the user for each host and meantime enable sudo command;
add_user $user_name $ip_dir
if [ $? -gt 0 ]
then 
    echo "Failed to add user!"
    echo "Leaving the program..."
    return 1
fi

#Update the hostnames and synchronize the /etc/hosts among hosts;
echo "Let's now set the hostname for each host and synchronise the /etc/hosts file among them."
edit_hosts $ip_dir
if [ $? -gt 0 ]
then 
    echo "Failed to edit hostnames!"
    echo "Leaving the program..."
    return 1
fi

#Ensure ssh-login without password among hosts in the cluster;
echo "Let's enable ssh-login without password among hosts."
enable_ssh_without_pwd $user_name $ip_dir

#Download jdk1.8 and configure it locally;
echo "Let's start to download and install jdk1.8 locally..."
install_jdk_local

#Download hadoop2.7 and configure it locally;
echo "Let's just download and install hadloop locally..."
install_hadoop $ip_dir
if [ $? -gt 0 ]
then 
    echo "Configure hadoop xml files now."
    echo "Leaving the program..."
    return 1
fi


echo "It's time to install and configure jdk1.8 and hadoop2.7 for all hosts in the cluster..."
configure_environment_variables "conf" $ip_dir $user_name

