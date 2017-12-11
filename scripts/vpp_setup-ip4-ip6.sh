#!/bin/bash

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`
DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::99"

echo 'No parameters provided. Running in default mode:'
echo 'vpp_setup-mixed-interfaces.sh'
echo "Prefix:$PREFIX"

# Setting ARPs
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P0 $DEFAULTIP $MACLC1P0
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP
sleep 0.1

# Promiscuous mode on. Optional
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P1
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P0

sleep 0.1

# Setting IP
echo "IPV4"

sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P1 $IPLC0P1/32
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P0 $IPLC0P0/32

sleep 0.1

##IPV6
echo "IPV6"

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P0 $IP6LC0P0/128
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P1 $IP6LC0P1/128
sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add ::/0 via $DEFAULTIP6 $NAMELC0P0
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip6 neighbor $NAMELC0P0 $DEFAULTIP6 $MACLC0P1 static

###
echo "Status up"

sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P1 up
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P0 up
