#!/bin/bash


if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Running in default mode:'
    echo 'linecard.sh [list of linecards to set]'

    #Setting IP
	sudo $SFLAG vppctl -p vpp set int ip address $NAMELC1P0 $IPLC1P0/24
	sudo $SFLAG vppctl -p vpp set int ip address $NAMELC1P1 $IPLC1P1/24

	# Setting ARPs
	sudo $SFLAG vppctl -p vpp set ip arp static $NAMELC1P0 $IPLC0P0 $MACLC0P0

	sudo $SFLAG vppctl -p vpp set interface state $NAMELC1P0 up
	sudo $SFLAG vppctl -p vpp set interface state $NAMELC1P1 up

    exit 1
fi

echo "Configuring Linecards for IP mode"

# Optional: add ip addresses to check ping

# Show for sanity check
#vppctl -p vpp show int address
