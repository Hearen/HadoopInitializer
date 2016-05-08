#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-05-05 11:14
#Description : user_name is hard-coded to "hadoop"
#           used to add user and group;
#           enabling ssh login without password among hosts;
#           updating hostnames of hosts in the cluster;
#           downloading jdk and configure it;
#           downloading hadoop and configure it;
#####################################################################################

. ./checker.sh

user_name="hadoop"

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

#Root privilege required
function add_user {
    HADOOP_USER=$1
    echo "Adding a user for later use: "
    useradd $HADOOP_USER
    passwd $HADOOP_USER
    usermod -aG wheel $HADOOP_USER
    echo "User $HADOOP_USER added to group wheel successfully!"
    echo "Now you can use sudo to run privileged commands."
}

add_user $user_name



#download and configure jdk;#

#Ensure the network connection is okay;
#check_fix_network
#if [ $? -eq 0 ]
#then
    #echo "Connection Okay!"
#fi

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

#Root privilege required
#converting all the ips in the file to hostnames
#the first will be hadoop-master while all the rest
#will be hadoop-slaveX; X ranges from 1 to n-1;
#then update all the hostnames accordingly;
function edit_hosts {
    if [ $(id -u) -gt 0 ]
    then
        echo "Permission denied, try to use su or sudo to gain privileged."
        return 1
    fi
    echo "It's time to edit hosts for all the hosts in the hadoop cluster."
    count=0
    rm -rf hosts
    touch hosts
    for ip in $(cat $1)
    do
        ip_checker $ip
        if [ $? -gt 0 ]
        then
            echo "Wrong IP, check the IPs in $dir";
            return 1
        fi
        if [ $count -eq 0 ]
        then
            hostname="hadoop-master"
        else
            hostname="hadoop-slave$count"
        fi
        count=$[count+1]
        echo "$ip $hostname" >> hosts
        echo "update the hostname of $ip to $hostname"
        ssh $ip hostnamectl set-hostname $hostname --static
    done
    for ip in $(cat $1)
    do 
        echo "updating the /etc/hosts of $ip"
        cat hosts | ssh $ip "cat > /etc/hosts"
    done
}

#edit_hosts "ips"

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
    #read -p "Input the file containing all the IPs in the cluster: " dir
    dir=$2
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
#enable_ssh_without_pwd "hadoop" "ips"


#root privilege required
#download jdk1.8 and configure java, javac and jre;
function install_jdk_local {
    cd /opt
    echo "Start to download jdk 1.8 for 64-bit machine..."
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.tar.gz"
    tar xzf jdk-8u77-linux-x64.tar.gz
    cd /opt/jdk1.8.0_77/
    echo "Configuring jdk now..."
    alternatives --install /usr/bin/java java /opt/jdk1.8.0_77/bin/java 2
    alternatives --config java
    echo "Configuring jar and javac now..."
    alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_77/bin/jar 2
    alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_77/bin/javac 2
    alternatives --set jar /opt/jdk1.8.0_77/bin/jar
    alternatives --set javac /opt/jdk1.8.0_77/bin/javac
    echo "Now, you may check java by java -version"
}

install_jdk_local

#root privilege required
#install hadoop via root privilege
#change the owner of the hadoop directory to user_name
function install_hadoop {
    cd /home/$user_name
    wget http://apache.claz.org/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz
    tar xzf hadoop-2.7.1.tar.gz
    mv hadoop-2.7.1 hadoop
    chown -R $user_name:$user_name hadoop
}

install_hadoop 

#root privilege required
#copy all the essential jdk and hadoop files to 
#remotes and configure its environment variables;
function configure_environment_variables {
    conf_dir=$1
    ip_dir=$2
    for ip in $(cat $ip_dir)
    do
        echo "Copy all the essential jdk files to $ip..."
        scp -r /opt/jdk1.8.0_77/ $ip:/opt/
        echo "Copy all the essential hadoop files to $ip..."
        scp -r /home/$user_name/hadoop $user_name@$ip:/home/$user_name/
        echo "Trying to configure environment variables for $ip"
        cat $conf_dir | ssh $ip "cat >> /etc/profile && source /etc/profile"
    done
}

configure_environment_variables "conf" "ips"
