#!/bin/bash
#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Thu, 2016-05-05 14:46
#Description : Used to logout from ISCAS internal network;
#####################################################################################
. login.sh

function send_logout_request {
    t=$(date +%s)
    echo "Trying to send logout request..."
    curl http://133.133.133.150/ajaxlogout?_t=$t >/dev/null
    echo
}

function logout_network {
    while [ 1 ]
    do
        send_logout_request
        return_code=`check_network "cn.bing.com"`
        if [ $return_code -eq 200 ]
        then 
            echo "Failed! retry in 1 second"
            sleep 1
        else
            echo "Log out successfully!"
            break
        fi
    done
}

#logout_network
