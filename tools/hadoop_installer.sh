#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-11-29 15:29
#Description : Install hadoop locally;
#####################################################################################


# Install hadoop by unzipping the compressed file and rename the folder;
function install_hadoop_local {
    if [ -f "$HADOOP_ORIGINAL_FILE" ] #check whether hadoop-*.*.*.tar.gz exists or not;
    then 
        echo "$HADOOP_ORIGINAL_FILE already exists, needless to download."
    else
        echo "Start to download $HADOOP_ORIGINAL_FILE ..."
        wget -O $HADOOP_ORIGINAL_FILE $HADOOP_SRC_URL
        if [ $? -gt 0 ]
        then
            return 1
        fi
    fi
    if [ -d "$HADOOP_FILE" ] #check whether hadoop-*.*.*.tar.gz unzipped or not;
    then
        echo "directory $HADOOP_FILE already exists, needless to install."
    else
        rm -rf $HADOOP_UNZIPPED_FILE
        tar -xzf $HADOOP_ORIGINAL_FILE -C $HADOOP_UNZIPPED_DIR && mv -f $HADOOP_UNZIPPED_FILE $HADOOP_FILE
    fi
    return 0
}

# To directly run this script to add a certain user for a cluster of remotes
# Uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
install_hadoop_local
