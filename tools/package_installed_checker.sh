#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-30 14:55
# Description : Check the package is installed or not;
#-------------------------------------------

# Check the existence of a certain package by RPM Package Manager
# And try to install it by `yum install`if it was not installed
#
# Attention: 
# 1. Root privilege required;
# 2. Checking process is done by `rpm -aq`, so and if the package cannot 
#    be checked by `rpm`, it will return true; in this case perhaps you 
#    can utilize command `which package_name`
# 3. Installation is done by command `yum`, if the package cannot be 
#    installed by `yum install` the installing process will be terminated 
#    abnormally and if the internet is okay then you should try to install 
#    it manually since it cannot be installed by `yum install`.
function check_package {
    package=$1
    check=`rpm -qa | grep $package`
    if [ -z "$check" ]
    then
        highlight_str 1 "Tool - $package is not installed."
        echo "To run the program properly, we have to install it first."
        highlight_substr 2 "Automatically installing " "$package" "..."
        yum install -y $package 1>/dev/null 2>/dev/null
        if [ $? -eq 0 ] 
        then
            highlight_substr 2 "" "$package" " successfully installed!" "" 
            return 0
        else # if the package is not found, yum install will return non-zero;
            highlight_str 1 "Failed installing "$package"."
            highlight_str 2 "Make sure you're connected to the internet" 
            highlight_str 2 "Or perhaps you need to install $package manually."
            return 1
        fi
    else
        highlight_substr 2 "" "$package" " already installed!" 
        return 0
    fi
}

# Uncomment the following lines to test this script directly;
BASE_DIR=${BASE_DIR:-${PWD%"Hadoop"*}"HadoopInitializer"}
source $BASE_DIR"/conf_loader.sh"
loadBasic;
source $TOOLS_DIR"/highlighter.sh"
source $TOOLS_DIR"/root_checker.sh"
echo "Essential parameters and scripts are loaded!"
echo "root privilege is required to run this script."
check_permission 
if [ $? -gt 0  ] 
then 
    echo "Leaving..."
    exit 1
fi
check_package "hadoop"
