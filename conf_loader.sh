#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-29 10:42
# Description : Used to load all the essential configurations under etc directory
#       and scripts under tools directory;
#-------------------------------------------
BASE_DIR=${BASE_DIR:-${PWD%"HadoopInitializer"*}"HadoopInitializer"}
ETC_DIR=$BASE_DIR"/etc"
TOOLS_DIR=$BASE_DIR"/tools"

function loadAll {
    for conf in $ETC_DIR"/*"
    do 
        #echo $conf
        source $conf
    done 
    for tool in $TOOLS_DIR"/*.sh";
    do
        #echo $tool;
        source $tool;
    done
}

function loadBasic {
    for conf in $ETC_DIR"/*"
    do 
        #echo $conf
        source $conf
    done 
    source $TOOLS_DIR"/highlighter.sh"
    source $TOOLS_DIR"/root_checker.sh"
    source $TOOLS_DIR"/ip_checker.sh"
    source $TOOLS_DIR"/user_checker.sh"
    source $TOOLS_DIR"/login.sh"
}

# For test only, uncomment the following lines;
#loadAll;
#./login.sh

