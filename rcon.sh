#!/bin/bash

source rcon_settings.txt
exec mcrcon -c -H localhost -P $port -p $password "$*"

