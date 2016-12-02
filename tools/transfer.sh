#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-14 15:05
# Description : Used to dispatch or delegate files to a cluster
#-------------------------------------------

# Transfer files to a specified cluster of remotes by scp
#
# ToDo:
# Utilize Expect to automate the password-input issue
function transfer {
	ips_file=$1
	src=$2
    des=${3:-"/home/"}
	for ip in $(cat $ips_file)
	do
	    scp $src $ip:$des
	done
}


# To directly run this script to transfer files to a cluster
# Uncomment the following lines;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#transfer $IPS_FILE "traffic_controller.sh"
