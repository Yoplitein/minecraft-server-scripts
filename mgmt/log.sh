#!/bin/bash

source $(dirname $(readlink -f $0))/common.sh

unit=
optparse=`getopt -o u:h -l unit:,help -- "$@"`

if [ ! $? -eq 0 ]; then
    exit 1
fi

eval set -- $optparse

while true; do
    case $1 in
        -h|--help)
            echo "$(basename $0) <--unit <unit>>"
            echo "Follows the server log."
            echo "To exit: use q or ctrl+c"
            exit
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
    if unit=$(guessUnitName); then
        echo "Assuming unit name $unit"
    else
        echo "You must specify a unit name. E.g. $(basename $0) -u vanilla110"
        exit 1
    fi
fi

jctl -alfu minecraft@$unit
