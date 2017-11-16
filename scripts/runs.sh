#!/bin/bash

source /home/leos/vpp-bench/scripts/config.sh
PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

#sudo $SFLAG $BINS/vppctl -p $PREFIX $1
sudo $SFLAG $BINS/vppctl -p $PREFIX $@

