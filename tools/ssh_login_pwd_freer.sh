#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-28 20:38
# Description : Used to enable password-less ssh login among remotes;
#-------------------------------------------

# Hadoop user required;
# Used to enable ssh-login to one another among hosts without password
# IP addresses are provided in a file
#
# ToDo:
# Utilize Expect to automate the password-input issue;
function enable_ssh_without_pwd {
    user_name=$1
    password=$2
    ips_file=$3
    echo
    tput bold
    highlight_str 4 "The whole process might take few minutes to finish."
    highlight_str 4 "Before the final bold prompt, do not stop it manually!"
    echo 
    user_checker $user_name
    if [ $? -gt 0 ]
    then 
        highlight_substr 4 "The current user should be the working user [" "$user_name" "]."
        highlight_substr 4 "You can use" " su $user_name " "to achieve this and then re-try."
        return 1
    fi
    for localhost in $(cat $ips_file) #traverse each line of the file - each IP address;
    do
        highlight_substr 6 "" "Generating rsa keys for [$localhost]" ""
        $TOOLS_DIR"/pwd_free_ssh_generator.exp" $user_name $password $localhost
    done
    for localhost in $(cat $ips_file)
    do
        for ip in $(cat $ips_file)
        do
            highlight_substr 6 "" "Copy rsa public key from [$localhost] to [$ip]" ""
            $TOOLS_DIR"/copy_ssh_key.exp" $user_name $password $localhost $ip
            echo 
            if [ $? -eq 0 ]
            then
                highlight_substr 1 "" "You can ssh login [$ip] from [$localhost] without password now!" ""
            fi
        done
    done
    echo
    tput bold
    highlight_str 2 "All the hosts in the cluster can log in one another without password!"
    return 0
}

# To directly execute the script, uncomment the following lines;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
enable_ssh_without_pwd $1 $2 $IPS_FILE

