#!/bin/bash

cd $RTE_PKTGEN
echo "Using pkt_gen: %RTE_PKTGEN"

if [[ $# -eq 0 ]] ; then
    echo 'STARTING PKTGEN WITH DEFAULT PARAMETERS' 
    echo '(cores: 12-16; [LC1P1, port0, rx] [LC1P2, port1, tx] ).' 
	sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 12,13-16 -n 1 -w $LC1P1 -w $LC1P2 -- -P -T -m "[13-14].0,[15-16].1" `pktgenconf.sh`
fi
