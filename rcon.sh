#!/bin/bash

source $(dirname $(readlink -f $0))/common.sh
source ~/$(guessUnitName)/rcon_settings.txt
exec /usr/bin/mcrcon -c -H localhost -P $port -p $password "$*"

