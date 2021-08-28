#!/bin/bash

rcon=$(dirname $(readlink -f $0))/../mgmt/rcon.py
$rcon "execute at $1 run summon minecraft:lightning_bolt"
