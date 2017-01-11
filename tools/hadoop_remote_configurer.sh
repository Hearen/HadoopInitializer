#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-11-30 10:50
#Description : Copy the hadoop configuration files to remotes;
#####################################################################################

# Copy the customized Hadoop configuration files
# To all the remotes to complete the cluster configuration
function copy_hadoop_configuration_files {
    highlight_str 6 "Start to copy hadoop configuration files to all remotes..." 
    for ip in $(cat $IPS_FILE); do
        highlight_str 6 "To [$ip]"
        for xml_file in "$HADOOP_CONF_DIR"/*; do 
            $TOOLS_DIR"/copy_local_file.exp" "$xml_file" $USER_NAME $PASSWORD $ip "$HADOOP_CONF"
        done
    done
}
 

# To execute the program directly, uncomment the following lines
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
#check_permission 
#if [ $? -gt 0  ] 
#then 
    #echo "Leaving..."
    #exit 1
#fi
copy_hadoop_configuration_files

