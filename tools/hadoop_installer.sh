#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-11-29 15:29
#Description : Install hadoop locally;
#####################################################################################

#Root privilege required
#Install hadoop by unzipping the compressed file and rename the folder;
function install_hadoop_local {
    if [ -f "$HADOOP_ORIGINAL_FILE" ] #check whether hadoop-2.7.1.tar.gz exists or not;
    then 
        echo "$HADOOP_ORIGINAL_FILE already exists, needless to download."
    else
        echo "Start to download $HADOOP_ORIGINAL_FILE ..."
        wget -O $HADOOP_ORIGINAL_FILE http://apache.claz.org/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz
        if [ $? -gt 0 ]
        then
            return 1
        fi
    fi
    if [ -d "$HADOOP_FILE" ] #check whether hadoop-2.7.1.tar.gz unzipped or not;
    then
        echo "directory $HADOOP_FILE already exists, needless to install."
    else
        rm -rf $HADOOP_UNZIPPED_FILE
        tar xzf $HADOOP_ORIGINAL_FILE -C $HADOOP_UNZIPPED_DIR 
        mv -f $HADOOP_UNZIPPED_FILE $HADOOP_FILE
    fi
    return 0
}

#install_hadoop_local
