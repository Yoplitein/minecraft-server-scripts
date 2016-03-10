#!/bin/bash

password=$(cat rcon_password.txt)

exec mcrcon -c -H localhost -P 38001 -p $password "$*"

