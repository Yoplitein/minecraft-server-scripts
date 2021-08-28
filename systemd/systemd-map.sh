#!/bin/bash

function rcon()
{
    $(dirname $(readlink -f $0))/../mgmt/rcon.py "$*"
    
    if [ $? -eq 255 ]; then
        echo "Server is down!"
        exit 1
    fi
}

rcon say Running map render
$(dirname $(readlink -f $0))/../utils/rendermap.sh --quiet
rcon say Map render complete
