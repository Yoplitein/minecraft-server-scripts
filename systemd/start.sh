#!/bin/bash

# Forge 1.16+
forgeJVMFlags=( libraries/net/minecraftforge/forge/*/unix_args.txt )
if [ -e $forgeJVMFlags ]; then
    exec env java -Xms${MEM_MIN} -Xmx${MEM_MAX} $JVM_ARGS @$forgeJVMFlags $MC_ARGS
elif [ -e server.jar ]; then
    # legacy
    exec env java -Xms${MEM_MIN} -Xmx${MEM_MAX} $JVM_ARGS -jar server.jar $MC_ARGS
else
    echo "Don't know how to launch server in $PWD"
    exit 1
fi
