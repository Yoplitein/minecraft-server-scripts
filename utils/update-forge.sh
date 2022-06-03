#!/bin/bash

set -e

if [ "$1" == "" ]; then
    echo "$(basename $0) [version]"
    exit 1
fi

version=$1
url="http://files.minecraftforge.net/maven/net/minecraftforge/forge/$version/forge-${version}-installer.jar"

# nuke older versions so the launch script doesn't get confused -- it naively globs
[ -d libraries ] && rm -rf libraries/

wget $url
java -jar forge-${version}-installer.jar --installServer
rm -vf forge-${version}-installer.jar{,.log}

newJar="forge-${version}.jar"

if [ ! -e $newJar ]; then
    echo "Forge jar naming scheme seems to have changed, expected $newJar"
    exit 1
fi

if [ -e server.jar ]; then
    serverJar=$(readlink server.jar)
    
    if [ -n "$serverJar" ] && [[ "$serverJar" != minecraft* ]] && [ "$serverJar" != "$newJar" ]; then
        rm -vf $serverJar
    fi
fi

ln -vfs $newJar server.jar
