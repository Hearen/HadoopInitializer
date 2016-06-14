#!/bin/bash

function transfer {
	ips_file=$1
	file=$2
	for ip in $(cat $ips_file)
	do
	    scp $file $ip:/home/
	done
}

transfer "etc/ips_file" "traffic_controller.sh"
