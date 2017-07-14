#!/bin/bash

EXP=""

vpp_compile.sh
vpp_start-default.sh vpp$RANDOM &
sleep 15
vpp_set-linecards-address.sh

# Add ip table here

# NO NEED FOR SCREEN!
dpdk_start-pktgen.sh $CONFIG_DIR/lua_vector-distribution.lua   #Start pktgen measuring forwarding rate

sudo killall vpp_main
sudo killall pktgen
sudo rm /dev/hugepages/*

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
