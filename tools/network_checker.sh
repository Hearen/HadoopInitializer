#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-01 10:24
# Description : Check the availability of the network
#   connection and try to fix it automatically.
#-------------------------------------------

# Check the availability of network connection
# By command curl and retrieve its return code
# Since ping is senseless when there are firewalls
# What's more, the script will also try to fix it.
# 
# Attention:
# The fixing is actually to restart the network service
# And to post the log-in info to the ISCAS gateway and
# Gain the access to the external network;
# So if the network environment is different, the connection
# Issue then should be handled manually by other methods.
function check_fix_network {
    return_code=`check_network "baidu.com"`
    if [ $return_code -eq 200 ]
    then
        highlight_str 2 "Network available"
    else
        highlight_str 1 "Connection error!"
        echo "Trying to fix the network..."
        login_network
        if [ $? -gt 0 ]
        then
            highlight_str 1 "Failed to fix the connection."
            echo "Remember sometimes 'ping works' does not mean you can access network normally and install online packages."
            echo "You have to fix the network by yourself now."
            echo "Leaving the script..."
            return 1
        fi
        return_code=`check_network "baidu.com"`
        if [ $return_code -eq 200 ]
        then
            return 0
        fi 
    fi
}

# To execute the program directly, uncomment the following lines
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
source $TOOLS_DIR"/highlighter.sh"
source $TOOLS_DIR"/root_checker.sh"
source $TOOLS_DIR"/login.sh"
echo "Essential parameters and scripts are loaded!"
echo "Root privilege is required"
check_permission 
if [ $? -gt 0  ] 
then 
    echo "Leaving..."
    exit 1
fi

check_fix_network

