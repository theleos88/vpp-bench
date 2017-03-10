#!/bin/bash

echo -e "set ip src 1 $IPLC1P2 \c"
echo -e "set ip dst 1 $IPLC1P1 \c"
echo -e "set mac 1 $MACLC2P2 \c"

echo -e "set ip src 0 $IPLC1P1 \c"