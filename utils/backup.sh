#!/bin/bash

export BUP_DIR=./bup

function rcon()
{
    $(dirname $(readlink -f $0))/../mgmt/rcon.py -n "$*"
    
    if [ $? -eq 255 ]; then
        echo "Server is down!"
        exit 1
    fi
}

function purge()
{
    if [ $(bup ls -n world 2>/dev/null | wc -l) -gt 100 ]; then
        echo "Rotating bup directories"
        rm $BUP_DIR.old -rf
        mv $BUP_DIR $BUP_DIR.old
        mkdir $BUP_DIR
        bup init
    fi
}

function backup()
{
    rcon say Backing up world
    rcon save-off
    rcon save-all flush
    sleep 10
    bup index world/
    bup save -n world world/
    rcon save-on
    rcon say Backup complete
}

function main()
{
    if [ ! -e $BUP_DIR ]; then
        mkdir $BUP_DIR
        bup init
    fi
    
    purge
    backup
}

main $@

