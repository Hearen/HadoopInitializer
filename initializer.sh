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

HADOOP_USER="hadoop0"
echo "Adding a user for later use: "
useradd $HADOOP_USER
passwd $HADOOP_USER
echo "User $HADOOP_USER added successfully!"


#download and configure jdk;#

#Ensure the network connection is okay;
check_fix_network
if [ $? -eq 0 ]
then
    echo "Connection Okay!"
fi


