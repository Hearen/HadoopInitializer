#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-14 15:05
# Description : Used to transfer files among hosts
#-------------------------------------------

function transfer {
	ips_file=$1
	file=$2
	for ip in $(cat $ips_file)
	do
	    scp $file $ip:/home/
	done
}

transfer "etc/ips_file" "traffic_controller.sh"
