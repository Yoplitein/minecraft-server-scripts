#!/bin/bash

if [ "$1" == "" ]; then
    echo "$(basename $0) [version]"
    exit 1
fi

version=$1
serverJar=minecraft_server.$version.jar

rm -vf minecraft_server.*.jar
wget https://s3.amazonaws.com/Minecraft.Download/versions/$version/minecraft_server.$version.jar
rm -vf server.jar
ln -vs $serverJar server.jar
