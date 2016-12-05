#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-30 14:55
# Description : Check the package is installed or not;
#-------------------------------------------

function command_available {
    command_name=$1
    check=`rpm -qa | grep $command_name`
    if [ ! -z "$check" ]
    then
        return 0;
    fi
    which $command_name 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        return 0;
    fi
    return 1;
}

# Check the existence of a certain package by RPM Package Manager
# And try to install it by `yum install`if it was not installed
#
# Attention: 
# 1. Root privilege required;
# 2. Checking process is done by `rpm -aq`, so and if the package cannot 
#    be checked by `rpm`, it will return true; in this case perhaps you 
#    can utilize command `which command`
# 3. Installation is done by command `yum`, if the package cannot be 
#    installed by `yum install` the installing process will be terminated 
#    abnormally and if the internet is okay then you should try to install 
#    it manually since it cannot be installed by `yum install`.
function check_package {
    command_name=$1
    #check=`rpm -qa | grep $package`
    #if [ -z "$check" ]
    command_available "$command_name"
    if [ $? -gt 0 ]
    then
        highlight_str 1 "Tool - $command_name is not installed."
        echo "To run the program properly, we have to install it first."
        highlight_substr 2 "Automatically installing " "$command_name" "..."
        yum install -y $command_name 1>/dev/null 2>/dev/null
        if [ $? -eq 0 ] 
        then
            highlight_substr 2 "" "$command_name" " successfully installed!" "" 
            return 0
        else # if the command_name is not found, yum install will return non-zero;
            highlight_str 1 "Failed installing "$command_name"."
            highlight_str 2 "Make sure you're connected to the internet" 
            highlight_str 2 "Or perhaps you need to install $command_name manually."
            return 1
        fi
    else
        highlight_substr 2 "" "$command_name" " already installed!" 
        return 0
    fi
}


function check_essential_packages {
    check_package "ssh"
    if [ $? -gt 0 ]
    then
        return 1;
    fi
    check_package "wget"
    if [ $? -gt 0 ]
    then
        return 1;
    fi
    check_package "curl"
    if [ $? -gt 0 ]
    then
        return 1;
    fi
    check_package "tar"
    if [ $? -gt 0 ]
    then
        return 1;
    fi
    return 0;
}

# Uncomment the following lines to test this script directly;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#echo "Essential parameters and scripts are loaded!"
#echo "root privilege is required to run this script."
#check_permission 
#if [ $? -gt 0  ] 
#then 
    #echo "Leaving..."
    #exit 1
#fi
#check_package "hadoop" # Some packaged need to be installed manually
#check_package "wget"
#check_package "scp"
#check_package "sscp"

