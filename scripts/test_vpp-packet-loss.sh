#!/bin/bash

EXP=""


# We can skip configuration since we're generating traffic from outside

#vpp_compile.sh
#vpp_start-default.sh vpp$RANDOM &
#sleep 15
#vpp_setup-xconnect.sh


#vpp_set-linecards-address.sh

# Add ip table here

#dpdk_start-pktgen.sh $CONFIG_DIR/lua_vector-distribution.lua   #Start pktgen measuring forwarding rate



export LC_NUMERIC="en_US.UTF-8"
cd $MOONDIR

inrate=$(echo "scale=2; $1/1.31" | bc)
rmoon=`printf %.0f $inrate`

sleep 4

echo "Testing at Rate $rmoon or $inrate"

runs.sh "clear run"
runs.sh "clear interfaces"

sudo ./build/MoonGen $CONFIG_DIR/moongen_txgen/single_tx.lua --dpdk-config=/home/leos/vpp-bench/scripts/moongen_txgen/dpdk-conf.lua 1 -f 1 -r $rmoon  > /tmp/moon.dat &

sleep 35

#a='event-logger save'
#b=" xc."$1".dat"
#runs.sh "$a$b"

OUTFILE = /tmp/xc.$1.pktloss.dat

runs.sh "show run" > $OUTFILE
runs.sh "show int" >> $OUTFILE
echo "------------------------"  >> $OUTFILE
grep "TX" /tmp/moon.dat >> $OUTFILE

#sudo killall vpp_main
sudo killall MoonGen
sudo rm /dev/hugepages/*

sleep 1

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
