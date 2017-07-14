#!/bin/bash

DEFAULTIP="99.99.99.99"

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`


if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Running in default mode:'
    echo 'linecard.sh [list of linecards to set]'
    echo Prefix:$PREFIX


	# Setting ARPs
	sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC1P0 $DEFAULTIP $MACLC0P0
    sleep 0.2
    sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP

    sleep 0.2

    sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC1P1
    sleep 0.2
    sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC1P0

    sleep 0.2

    #Setting IP
	sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC1P1 $IPLC1P1/32
    sleep 0.2
	sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC1P0 $IPLC1P0/32

    sleep 0.2

	sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC1P1 up
    sleep 0.2
	sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC1P0 up
    sleep 0.2

    exit 1
fi

echo "Configuring Linecards for IP mode"

# Optional: add ip addresses to check ping

# Show for sanity check
#vppctl -p $PREFIX show int address
