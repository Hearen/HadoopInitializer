#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-11-30 10:50
#Description : Copy the hadoop configuration files to remotes;
#####################################################################################

# Copy the customized Hadoop configuration files
# To all the remotes to complete the cluster configuration
#
# ToDo:
# Utilize Expect to automate the password-input issue;
function copy_hadoop_configuration_files {
    highlight_str 6 "Start to copy hadoop configuration files to all remotes..." 
    for ip in $(cat $IPS_FILE)
    do
        highlight_str 6 "To [$ip]"
        sh -c "echo $HHADOOP_DIR'/*'"
        scp $HHADOOP_DIR'/*' $USER_NAME@$ip:$HADOOP_CONF # for hadoop 2.7.1 only;
    done
}
 

# To execute the program directly, uncomment the following lines
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#source $TOOLS_DIR"/highlighter.sh"
#source $TOOLS_DIR"/root_checker.sh"
#echo "Essential parameters and scripts are loaded!"
#echo "root privilege is required to run this script."
#check_permission 
#if [ $? -eq 0  ] 
#then 
    #echo "Permission Granted." 
#else 
    #echo "Leaving..."
    #exit 1
#fi

#copy_hadoop_configuration_files;

