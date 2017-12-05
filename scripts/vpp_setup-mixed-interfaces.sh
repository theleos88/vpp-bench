#!/bin/bash

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`
DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::99"	# Updated with non-ffff


echo 'No parameters provided. Running in default mode:'
echo 'vpp_setup-mixed-interfaces.sh'
echo "Prefix:$PREFIX"

# Setting ARPs
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P0 $IPLC1P0 $MACLC1P0	#Leonardo: using Sal's config
#sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP	# Leonardo: no default route for mixed interfaces!!!
sleep 0.1

# Promiscuous mode on. Optional
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P1
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC0P0

sleep 0.1

# Setting IP
echo "IPV4"

#sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P1 $IPLC0P1/24	# Leonardo: no addresses here for mixed!!!
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P1 $IPLC0P1/32	# Leonardo: putting back address here
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P0 $IPLC0P0/32	# Leonardo: two addresses on the IFx where we go out.
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC0P0 192.168.2.0/24	#/24 Since this is for the bridge

sleep 0.1

echo "BRIDGING"

# Bridge interfaces
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge $NAMELC0P0 13
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge $NAMELC0P1 13

echo "LOOPBACK"

# Setup loop interface for routing
sudo $SFLAG $BINS/vppctl -p $PREFIX create loopback interface
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface mac address loop0 $MACLOOP
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address loop0 $IPLOOP/24	#Here also /24 because we need to trick


##IPV6
echo "IPV6"

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address loop0 $IP6LOOP/128
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P0 $IP6LC0P0/128
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC0P1 $IP6LC0P1/128
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add ::/0 via $DEFAULTIP6 $NAMELC0P0
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip6 neighbor $NAMELC0P0 $DEFAULTIP6 $MACLC0P1 static

###

sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge loop0 13 bvi
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state loop0 up

# Check here (?)
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 10.0.0.0/28 via $IPLC0P0
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 10.0.1.0/28 via $IPLC0P1

#learn the MAC of the src ip -  Check here as well (!?)
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P0 192.168.2.2 $MACLC1P0
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P1 192.168.2.4 $MACLC1P1
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P1 $IPLC0P0 90:e2:ba:cb:f5:48
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC0P1 $IPLC0P1 90:e2:ba:cb:f5:49	#Leonardo: found a bug!!!

echo "Status up"
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P1 up
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC0P0 up

#learn the MAC of the dst interface
sudo $SFLAG $BINS/vppctl -p $PREFIX l2fib add $MACLC0P1 13 $NAMELC0P0 static  # Original non-inverted

##
# test L2:
# enp11s0f0 --> TenGigabitEthernet84/0/0 --> TenGigabitEthernet84/0/1 --> enp11s0f1 (tcpdump -Q in -enqi enp11s0f1)
# ping -I enp11s0f0 192.168.2.4  
# enp11s0f1 --> TenGigabitEthernet84/0/1 --> TenGigabitEthernet84/0/0 --> enp11s0f0 (tcpdump -Q in -enqi enp11s0f0)
# ping -I enp11s0f1 192.168.2.2 

# test L3:
# enp11s0f0 --> TenGigabitEthernet84/0/0 --> TenGigabitEthernet84/0/1 --> enp11s0f1 (tcpdump -Q in -enqi enp11s0f1)
# ping -I enp11s0f0 10.0.0.15 
# enp11s0f1 --> TenGigabitEthernet84/0/1 --> TenGigabitEthernet84/0/0 --> enp11s0f0 (tcpdump -Q in -enqi enp11s0f1)
# ping -I enp11s0f1 10.0.1.15
