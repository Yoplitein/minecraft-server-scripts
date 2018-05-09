#!/bin/bash

source $(dirname $(readlink -f $0))/common.sh

unit=
force=false
optparse=`getopt -o u:fh -l unit:,force,help -- "$@"`

if [ ! $? -eq 0 ]; then
    exit 1
fi

eval set -- $optparse

while true; do
    case $1 in
        -h|--help)
            echo "$(basename $0) <--unit <unit>> [--force]"
            echo "Kills the server process."
            echo "--force => use more violent methods to kill the server"
            exit
            ;;
        -f|--force)
            force=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option '$1'"
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

signal=""
msgPostfix=""

if $force; then
    signal="--signal 9"
    msgPostfix=" violently"
fi

echo "Killing ${unit}${msgPostfix}"

ctl kill $signal minecraft@$unit
