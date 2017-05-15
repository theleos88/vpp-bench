#!/bin/bash


if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Running in default mode:'
    echo 'linecard.sh [list of linecards to set]'

    #Setting IP
	sudo $SFLAG $BINS/vppctl -p vpp set int ip address $NAMELC0P0 $IPLC0P0/32
	sudo $SFLAG $BINS/vppctl -p vpp set int ip address $NAMELC0P1 $IPLC0P1/32

	# Setting ARPs
	sudo $SFLAG $BINS/vppctl -p vpp set ip arp static $NAMELC0P0 $IPLC1P0 $MACLC1P0

	sudo $SFLAG $BINS/vppctl -p vpp set interface state $NAMELC0P0 up
	sudo $SFLAG $BINS/vppctl -p vpp set interface state $NAMELC0P1 up

    sudo $SFLAG $BINS/vppctl -p vpp set interface promiscuous on $NAMELC0P0
    sudo $SFLAG $BINS/vppctl -p vpp set interface promiscuous on $NAMELC0P1

    sudo $SFLAG vppctl -p vpp1 set interface promiscuous on $NAMELC0P1
    sudo $SFLAG vppctl -p vpp1 set interface promiscuous on $NAMELC0P0

    exit 1
fi

echo "Configuring Linecards for IP mode"

# Optional: add ip addresses to check ping

# Show for sanity check
#vppctl -p vpp show int address
