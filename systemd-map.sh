#!/bin/bash

function rcon()
{
    $(dirname $0)/rcon.sh $@
    
    if [ $? -eq 255 ]; then
        echo "Server is down!"
        exit 1
    fi
}

rcon say Running map render
$(dirname $0)/rendermap.sh --quiet
rcon say Map render complete
