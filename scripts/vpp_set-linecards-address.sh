#!/bin/bash

DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::ffff"

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Running in default mode:'
    echo 'linecard.sh [list of linecards to set]'
    echo Prefix:$PREFIX


	# Setting ARPs
	sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P0 $DEFAULTIP $MACLC1P0
    sleep 0.2
    sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP

    sleep 0.2

    #Setting IP
	sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P0 $IPLC0P0/32
    sleep 0.2
	sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P1 $IPLC0P1/32

    echo "Configuring Linecards for IP mode"

elif [[ $1 == "ip6" ]] ; then
    echo "Configuring LCs for IP6 mode"

    sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P0 $IP6LC0P0/128
    sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P1 $IP6LC0P1/128
    sleep 0.2

    sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add ::/0 via $DEFAULTIP6 $NAMELC0P0
    sudo $SFLAG $BINS/vppctl -p $PREFIX set ip6 neighbor $NAMELC0P0 $DEFAULTIP6 $MACLC0P1 static
    sleep 0.2
fi

echo "Finishing configuration"

sleep 0.2

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P1
sleep 0.2

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P0
sleep 0.2

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P1 up
sleep 0.2

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P0 up
sleep 0.2




# Optional: add ip addresses to check ping

# Show for sanity check
#vppctl -p $PREFIX show int address
