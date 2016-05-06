#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-05-05 11:14
#Description : Used to add user and group;
#           downloading jdk and configure it;
#           downloading hadoop and configure it;
#           enabling ssh login without password;
#####################################################################################

. ./checker.sh

#Ensure the role is root to execute some privileged commands;
check_permission 
if [ $? -eq 0  ] 
then 
    echo "Root Permission Granted." 
else 
    echo "Permission denied!" 
    echo "Make sure you are running this program in root or sudo command." 
    echo "Leaving the program..."
    exit 1
fi

function add_user {
    HADOOP_USER="hadoop0"
    echo "Adding a user for later use: "
    useradd $HADOOP_USER
    passwd $HADOOP_USER
    echo "User $HADOOP_USER added successfully!"
}



#download and configure jdk;#

#Ensure the network connection is okay;
check_fix_network
if [ $? -eq 0 ]
then
    echo "Connection Okay!"
fi

function check_hostname {
    if [ "$1" == "$2" ]
    then
        echo "New hostname set successfully!"
    else
        echo "Failed to set the new hostname, please check its format and retry later."
        echo "The hostname is [$2] while the hostname you set is [$1]."
    fi
    
}

#Used to set the hostname of a host preparing for hadoop cluster;
#first select the host type local host -> 0 while remote host -> 1;
#if it's local type, the user will be prompted to input the new hostname directly;
#but it it's remote type, the user input both the ip and the hostname;
function set_hostname {
    echo
    tput setaf 1
    echo "Set hostname for local or remote host." 
    tput setaf 6
    while [ 1 ]
    do
        read -n1 -p "Input 0 [local] or 1 [remote]: " type
        case $type in 
            0) 
                echo
                echo "Set hostname for local host."
                tput sgr0
                read -p "New hostname: " hostname
                hostnamectl set-hostname $hostname --static
                echo "Checking the result..."
                t=$(hostname)
                check_hostname $t $hostname
                #if [ "$t" == $hostname ]
                #then
                    #echo "New hostname set successfully!"
                #else
                    #echo "Failed to set the new hostname, please check its format and retry later."
                #fi
                return 0
                ;;
            1)
                echo
                echo "Set hostname for remote host."
                tput sgr0
                read -p "IP of the remote host: " ip
                read -p "New hostname: " hostname
                ssh root@$ip hostnamectl set-hostname $hostname --static
                echo "To verify the remote hostname, you need to re-input the password."
                t=$(ssh root@$ip hostname)
                check_hostname $t $hostname
                #if [ "$t" == $hostname ]
                #then
                    #echo "New hostname set successfully!"
                #else
                    #echo "Failed to set the new hostname, please check its format and retry later."
                #fi
                return 0
                ;;
            *)
                echo 
                tput setaf 1
                echo "Input Error. Please input 0 [local] or 1 [remote]!"
                echo
                ;;
        esac
    done
}


set_hostname
