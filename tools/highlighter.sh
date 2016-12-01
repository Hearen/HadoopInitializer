#!/bin/bash
#-------------------------------------------
# Author      : LHearen
# E-mail      : LHearen@126.com
# Time        : 2016-11-29 09:27
# Description : Highlight a substring with certain color;
#-------------------------------------------

# First parameter is the color, second the prefix
# Third the substring to be highlighted, fourth the suffix;
function highlight_substr {
    color="$1"
    prefix="$2"
    substr="$3"
    suffix="$4"
    echo -n "$2"
    tput setaf $color
    echo -n "$substr"
    tput sgr0
    echo "$4"
}

function highlight_str {
    color=$1
    str="$2"
    highlight_substr $1 "" "$2" ""
}

# To directly execute the script, uncomment the following lines;
#hightlight_substr 1 "hello " " world" ", Kacy!"
