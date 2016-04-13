#!/bin/bash

set -e

if [ "$1" == "" ]; then
    echo "$(basename $0) [version]"
    exit 1
fi

version=$1
url="http://files.minecraftforge.net/maven/net/minecraftforge/forge/$version/forge-${version}-installer.jar"

wget $url
java -jar forge-${version}-installer.jar --installServer
rm -vf forge-${version}-installer.jar{,.log}

serverJar=$(readlink server.jar)
newJar="forge-${version}-universal.jar"

if [ -n "$serverJar" ] && [[ "$serverJar" != minecraft* ]] && [ "$serverJar" != "$newJar" ]; then
    rm -vf $serverJar
fi

ln -vfs forge-${version}-universal.jar server.jar
