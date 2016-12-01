#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-06-03 11:25
# Description : Display the string at the center of the console;
#-------------------------------------------


# Used to center-align the text in console
# And highlight it by bold style;
function display_center {
    COLUMNS=$( tput cols )
    title=$1
    tput bold;
    printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
    tput sgr0;
}


# Uncomment the following lines to test the script directly;
#display_center "Hearen's Place"

