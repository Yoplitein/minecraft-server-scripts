#!/bin/bash

renderMap=true
generatePois=true
flags="-c overviewer-config.py"

while true; do
    case "$1" in
        -h | --help)
            echo "$0 [--no-map] [--no-poi] [--quiet]"
            exit
            ;;
        --no-map)
            renderMap=false
            ;;
        --no-poi)
            generatePois=false
            ;;
        --quiet)
            flags="$flags --quiet"
            ;;
        *)
            break
            ;;
    esac
    
    shift
done

if $renderMap; then
    overviewer.py $flags
fi

if $generatePois; then
    overviewer.py --genpoi $flags
fi
