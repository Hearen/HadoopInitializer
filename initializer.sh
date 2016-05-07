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
#check_permission 
#if [ $? -eq 0  ] 
#then 
    #echo "Root Permission Granted." 
#else 
    #echo "Permission denied!" 
    #echo "Make sure you are running this program in root or sudo command." 
    #echo "Leaving the program..."
    #exit 1
#fi

#This function has to be run in root;
function add_user {
    HADOOP_USER="hadoop0"
    echo "Adding a user for later use: "
    useradd $HADOOP_USER
    passwd $HADOOP_USER
    usermod -aG wheel $HADOOP_USER
    echo "User $HADOOP_USER added to group wheel successfully!"
    echo "Now you can use sudo to run privileged commands."
}



#download and configure jdk;#

#Ensure the network connection is okay;
#check_fix_network
#if [ $? -eq 0 ]
#then
    #echo "Connection Okay!"
#fi

#Check whether the current hostname $1 is equal to the newly set hostname $2
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


#set_hostname

function edit_hosts {
    echo "It's time to edit hosts for all the hosts in the hadoop cluster."
    echo "Using vim to insert the ip and hostname pairs in the /etc/hosts, save it and quit."
    vim /etc/hosts
    if [ $? -eq 0 ]
    then 
        echo "Done!"
    else
        echo "Failed!"
    fi
}

#edit_hosts

#the first parameter is the name of the user;
#the function is used to read all IPs in a file and enable login one another without password;
function enable_ssh_without_pwd {
    if [ $1 != `echo "$USER"` ] || [ `id -u` -eq 0 ] #ensure the current user is the user specified by parameter echo $USER is not enough we need id -u to filter further;
    then 
        echo "The current user should be the working user."
        echo -n "You can use"
        tput setaf 4 
        echo -n " su $1 "
        tput sgr0
        echo "to achieve this and then re-try."
        return 1
    fi
    read -p "Input the file containing all the IPs in the cluster: " dir
    for localhost in $(cat $dir) #traverse each line of the file - dir
    do
        ip_checker $localhost
        if [ $? -gt 0 ]
        then
            echo "Wrong IP, check the IPs in $dir";
            return 1
        fi
        tput setaf 6
        echo "Generating rsa keys for $localhost"
        tput sgr0
        ssh -t $localhost "rm -rf ~/.ssh && ssh-keygen -t rsa && touch /home/$1/.ssh/authorized_keys && sudo chmod 600 /home/$1/.ssh/authorized_keys" #-t is to force sudo command;
    done
    for localhost in $(cat $dir)
    do
        for ip in $(cat $dir)
        do
            tput setaf 6
            echo "Copy rsa public key from $localhost to $ip"
            tput sgr0
            ssh -t $localhost "ssh-copy-id -i ~/.ssh/id_rsa.pub $ip " ##enable the remote-host-ssh-login-local-without-password #option -t here is used to enable password required command;
            if [ $? -eq 0 ]
            then
                tput setaf 1
                echo "You can ssh login $ip from $localhost without password now!"
                tput sgr0
            fi
        done
    done
    return 0
}
enable_ssh_without_pwd "hadoop"
