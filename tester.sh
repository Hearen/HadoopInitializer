#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-12-05 15:32
# Description : Used to test the validity of the installation
#   and configuration of the hadoop in the cluster;
#-------------------------------------------

# Testing the hadoop installation and configuration;
function test_hadoop {
    user_name=$1
    user_checker "$user_name"
    if [ $? -gt 0 ] # ensure the current user is the user specified by parameter echo $USER is not enough we need id -u to filter further;
    then 
        highlight_substr 2 "The current user should be the working user [" "$USER_NAME" "]."
        highlight_substr 2 "You can use" " su $USER_NAME " "to achieve this and then re-try."
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

#BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadAll

#echo $IPS_FILE
#test_hadoop $USER_NAME
