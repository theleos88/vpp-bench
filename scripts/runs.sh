#!/bin/bash

source /home/leos/vpp-bench/scripts/config.sh
#source $CONFIG_DIR/config.sh
PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`


## Version 16.04
#sudo $SFLAG $BINS/vppctl -p $PREFIX $@

## Version 19.04
sudo $BINS/vppctl -s $PREFIX $@
