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
    highlight_str 6 "First format the HDFS..."
    hadoop namenode -format
    highlight_str 6 "Trying to start the hadoop..."
    start-all.sh
    highlight_str 6 "Checking the service..."
    jps
}

#BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadAll

#echo $IPS_FILE
#test_hadoop $USER_NAME
