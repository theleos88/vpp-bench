#!/bin/bash

PREFIX=`cat $STARTUP_CONF | grep cli-listen | awk '{print $2}' | xargs echo -n`
DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::ffff"

echo 'No parameters provided. Running in default mode:'
echo 'vpp_setup-mixed-interfaces.sh'
echo "Prefix:$PREFIX"

# Setting ARPs
sudo $SFLAG $BINS/vppctl -s $PREFIX set ip arp static $NAMELC1P0 $DEFAULTIP $MACLC0P0
sleep 0.1
sudo $SFLAG $BINS/vppctl -s $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP

# Promiscuous mode on. Optional
sudo $SFLAG $BINS/vppctl -s $PREFIX set interface promiscuous on $NAMELC1P1
sleep 0.1
sudo $SFLAG $BINS/vppctl -s $PREFIX set interface promiscuous on $NAMELC1P0

sleep 0.1

# Setting IP
echo "IPV6"

sudo $SFLAG $BINS/vppctl -s $PREFIX set int ip address $NAMELC1P1 $IPLC1P1/32
sleep 0.1
sudo $SFLAG $BINS/vppctl -s $PREFIX set int ip address $NAMELC1P0 $IPLC1P0/32

sleep 0.1

##IPV6
echo "IPV6"

sudo $SFLAG $BINS/vppctl -s $PREFIX set interface ip address $NAMELC1P0 $IP6LC1P0/128
sudo $SFLAG $BINS/vppctl -s $PREFIX set interface ip address $NAMELC1P1 $IP6LC1P1/128
sudo $SFLAG $BINS/vppctl -s $PREFIX ip route add ::/0 via $DEFAULTIP6 $NAMELC1P0
sudo $SFLAG $BINS/vppctl -s $PREFIX set ip6 neighbor $NAMELC1P0 $DEFAULTIP6 $MACLC1P1 static

###
echo "Status up"

sudo $SFLAG $BINS/vppctl -s $PREFIX set interface state $NAMELC1P1 up
sudo $SFLAG $BINS/vppctl -s $PREFIX set interface state $NAMELC1P0 up
