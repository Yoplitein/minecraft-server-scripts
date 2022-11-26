#!/bin/bash

source $(dirname $(readlink -f $0))/common.sh

defaultTime=30
defaultMsg="no reason given"
time=$defaultTime
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
    if unit=$(guessUnitName); then
        echo "Assuming unit name $unit"
    else
        echo "You must specify a unit name. E.g. $(basename $0) -u vanilla110"
        exit 1
    fi
fi

msg=${@-${defaultMsg}}
if $restart; then
    kickmsg="Server restarting: $msg"
else
    kickmsg="Server shutting down: $msg"
fi

echo "Stopping server in $time seconds: $msg"

ctl set-environment "TIME=$time"
ctl set-environment "MSG=$msg"
ctl set-environment "KICKMSG=$kickmsg"
ctl stop minecraft@$unit
ctl set-environment "TIME=$defaultTime"
ctl set-environment "MSG=$defaultMsg"

if $restart; then
    ctl start minecraft@$unit
fi
