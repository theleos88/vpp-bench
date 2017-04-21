#!/bin/bash


if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Running in default mode:'
    echo 'linecard.sh [list of linecards to set]'

    #Setting IP
	sudo $SFLAG $BINS/vppctl -p vpp set int ip address $NAMELC1P0 $IPLC1P0/32
	sudo $SFLAG $BINS/vppctl -p vpp set int ip address $NAMELC1P1 $IPLC1P1/32

	# Setting ARPs
	sudo $SFLAG $BINS/vppctl -p vpp set ip arp static $NAMELC1P0 $IPLC0P0 $MACLC0P0

	sudo $SFLAG $BINS/vppctl -p vpp set interface state $NAMELC1P0 up
	sudo $SFLAG $BINS/vppctl -p vpp set interface state $NAMELC1P1 up

    sudo $SFLAG $BINS/vppctl -p vpp set interface promiscuous on $NAMELC1P0
    sudo $SFLAG $BINS/vppctl -p vpp set interface promiscuous on $NAMELC1P1

    sudo $SFLAG vppctl -p vpp1 set interface promiscuous on $NAMELC1P1
    sudo $SFLAG vppctl -p vpp1 set interface promiscuous on $NAMELC1P0

    exit 1
fi

echo "Configuring Linecards for IP mode"

# Optional: add ip addresses to check ping

# Show for sanity check
#vppctl -p vpp show int address
