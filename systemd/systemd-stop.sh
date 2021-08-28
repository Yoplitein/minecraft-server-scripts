#!/bin/bash

function rcon()
{
    $(dirname $(readlink -f $0))/../mgmt/rcon.py "$*"
    
    if [ $? -eq 255 ]; then
        echo "Server is down!"
        exit 1
    fi
}

function main()
{
    if [ "$TIME" == "" ]; then
        TIME=30
    fi
    
    if [ "$MSG" != "" ]; then
        MSG=": $MSG"
    fi
    
    rcon say Server going down in $TIME seconds$MSG
    sleep $TIME
    rcon stop
    sleep 5
}

main $@

