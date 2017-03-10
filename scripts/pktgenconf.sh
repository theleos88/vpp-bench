#!/bin/bash

F=/tmp/pktgen.pkt

echo "set ip src 1 $IPLC1P2/24"  > $F
echo "set ip dst 1 $IPLC1P1" >> $F
echo "set mac 1 $MACLC2P2" >> $F

echo "set ip src 0 $IPLC1P1/24" >> $F

echo $F