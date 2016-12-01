#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-11-29 15:39
#Description : Check whether jdk 1.8 installed in remotes or not
#####################################################################################

# Return 1 if not installed otherwise return 0;
function java_checker {
    ip=$1
    user_name=$2
    ret=$(ssh $user_name@$ip "java -version; $JDK_FILE/bin/java -version" 2>&1 | sed -n "/1.8/p")
    echo $ret
    if [ "$ret" == "" ]
    then
        echo "java 1.8 not installed"
        return 1
    else
        echo "java 1.8 already installed"
        return 0
    fi
}

# To execute the program directly, uncomment the following lines
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#echo "loaded"
#java_checker "133.133.135.37" "hadoop"
