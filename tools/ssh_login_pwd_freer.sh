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
    ips_file=$2
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
        ssh -t $localhost "rm -rf ~/.ssh && ssh-keygen -t rsa && touch /home/$user_name/.ssh/authorized_keys && chmod 600 /home/$user_name/.ssh/authorized_keys" #-t is to force sudo command;
    done
    for localhost in $(cat $ips_file)
    do
        for ip in $(cat $ips_file)
        do
            highlight_substr 6 "" "Copy rsa public key from [$localhost] to [$ip]" ""
            ssh -t $localhost "ssh-copy-id -i ~/.ssh/id_rsa.pub $ip " ##enable the remote-host-ssh-login-local-without-password #option -t here is used to enable password required command;
            if [ $? -eq 0 ]
            then
                highlight_substr 1 "" "You can ssh login [$ip] from [$localhost] without password now!" ""
            fi
        done
    done
    return 0
}

# To directly execute the script, uncomment the following lines;
#BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
#source $BASE_DIR"/conf_loader.sh"
#loadBasic;
#source $TOOLS_DIR"/ip_checker.sh"
#source $TOOLS_DIR"/user_checker.sh"
#source $TOOLS_DIR"/highlighter.sh"
#enable_ssh_without_pwd $USER_NAME $IPS_FILE

