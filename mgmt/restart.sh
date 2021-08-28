#!/bin/bash

$(dirname $(readlink -f $0))/stop.sh -r $@
