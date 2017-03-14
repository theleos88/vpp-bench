#!/bin/bash

F=/tmp/pktgen.pkt

SIZE=80 #Default size
DELAY=10000 #Default delay

echo "set ip src 1 $IPLC1P2/24"  > $F
echo "set ip dst 1 $IPLC1P1" >> $F
echo "set mac 1 $MACLC2P2" >> $F

SIZE=$1
echo "set 1 size $SIZE" >> $F

echo "set ip src 0 $IPLC1P1/24" >> $F
echo "set 1 rate 100" >> $F
echo "start 1" >> $F

echo "delay $DELAY" >> $F
echo "stop 1" >> $F

echo $F