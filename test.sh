#!/bin/bash

COLUMNS=$( tput cols )
title="Hello world"
echo $COLUMNS

echo $title
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
