#!/bin/bash

time=30
unit=
restart=false
optparse=`getopt -o t:u:rh -l time:,unit:,restart,help -- "$@"`


if [ ! $? -eq 0 ]; then
    exit 1
fi

eval set -- $optparse

while true; do
    case $1 in
        -h|--help)
            echo "$(basename $0) <--unit <unit>> [--time <seconds>] <message>"
            exit
            ;;
        -t|--time)
            time=$2
            shift 2
            ;;
        -u|--unit)
            unit=$2
            shift 2
            ;;
        -r|--restart)
            restart=true
            shift 1
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option $1"
            break
            ;;
    esac
done

if [ -z "$unit" ]; then
    unit=$(basename $PWD)
    
    systemctl --user --quiet is-active minecraft@$unit
    
    if [ ! $? -eq 0 ]; then
        echo "Guessed unit \"minecraft@$unit\" does not appear to be valid"
        exit 1
    fi
fi

MSG=${@-no reason given}

systemctl --user set-environment "TIME=$time"
systemctl --user set-environment "MSG=$MSG"
systemctl --user stop minecraft@$unit
systemctl --user set-environment "MSG=no reason given"

if $restart; then
    systemctl --user start minecraft@$unit
fi
