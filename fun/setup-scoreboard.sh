#!/bin/bash

rcon=$(dirname $(readlink -f $0))/../mgmt/rcon.py

$rcon -n "scoreboard objectives add Deaths deathCount"
$rcon -n "scoreboard objectives setdisplay belowName Deaths"
$rcon -n "scoreboard objectives add HP health"
$rcon -n "scoreboard objectives setdisplay list HP"
