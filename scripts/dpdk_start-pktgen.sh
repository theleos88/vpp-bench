#!/bin/bash

echo "Starting dpdk packet-gen in default mode:"
echo "TX: $LC0P0, cores 13,14;" 
echo "RX: $LC0P1, corse 15,16"
echo ""
sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 12,13-16 -n 1 -w $LC0P0 -w $LC0P1 -- -P -T -m "[13-14].0,[15-16].1" 2> /tmp/logpktgen.log