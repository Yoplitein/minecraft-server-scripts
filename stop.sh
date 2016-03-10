#!/bin/bash

time=30
unit=
optparse=`getopt -o t:u:h -l time:,unit:,help -- "$@"`


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
    echo "Missing required --unit flag"
    exit 1
fi

MSG=${@-no reason given}

systemctl --user set-environment "TIME=$time"
systemctl --user set-environment "MSG=$MSG"
systemctl --user stop minecraft@$unit
systemctl --user set-environment "MSG=no reason given"
