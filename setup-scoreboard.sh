#!/bin/bash

rcon=$(dirname $(readlink -f $0))/rcon.sh

$rcon scoreboard objectives add Deaths deathCount
$rcon scoreboard objectives setdisplay belowName Deaths
$rcon scoreboard objectives add HP health
$rcon scoreboard objectives setdisplay list HP
