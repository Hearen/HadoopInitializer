#!/bin/bash

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-12-01 10:50
#Description : Download the JDK, install and configure it locally;
#####################################################################################

# Root privilege required
# Download jdk1.8 and configure java, javac and jre;
function install_jdk_local {
    if [ ! -d "$JDK_FILE " ]
    then
        if [ -f "$JDK_ORIGINAL_FILE" ]
        then
            echo "$JDK_ORIGINAL_FILE already exists, needless to download."
        else
            echo "Start to download jdk 1.8 for 64-bit machine..."
            wget -O $JDK_ORIGINAL_FILE --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.tar.gz"
            if [ $? -gt 0 ]
            then 
                return 1
            fi
        fi
        tar -zxvf $JDK_ORIGINAL_FILE -C $USER_HOME && mv $JDK_SOURCE_FILE $JDK_FILE
        echo "Configuring jdk now..."
        alternatives --install /usr/bin/java java $JDK_FILE/bin/java 2
        alternatives --config java
        echo "Configuring jar and javac now..."
        alternatives --install /usr/bin/jar jar $JDK_FIL/bin/jar 2
        alternatives --install /usr/bin/javac javac $JDK_FILE/bin/javac 2
        alternatives --set jar $JDK_FILE/bin/jar
        alternatives --set javac $JDK_FILE/bin/javac
        echo
        echo "Java installation completed!"
        echo "Now, you may check by 'java -version'"
        return 0
    fi
}

# To execute the program directly, uncomment the following lines
BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
install_jdk_local
