#!/bin/bash

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`
DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::ffff"


echo 'No parameters provided. Running in default mode:'
echo 'vpp_setup-mixed-interfaces.sh'
echo "Prefix:$PREFIX"

# Setting ARPs
echo "ARP + IP4"

sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static $NAMELC1P0 $DEFAULTIP $MACLC0P0
sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 0.0.0.0/0 via $DEFAULTIP

# Promiscuous mode on. Optional
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC1P1
sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface promiscuous on $NAMELC1P0

sleep 0.1

# Setting IP
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC1P1 $IPLC1P1/32
sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX set int ip address $NAMELC1P0 $IPLC1P0/32

sleep 0.1

echo "bridge"
# Bridge interfaces
# sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge $NAMELC1P0 13
# sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge $NAMELC1P1 13

echo "Create loopback"
# Setup loop interface for routing
sleep 0.1
sudo $SFLAG $BINS/vppctl -p $PREFIX create loopback interface
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface mac address loop0 $MACLOOP
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address loop0 $IPLOOP/32

##IPV6
echo "IP6"
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address loop0 $IP6LOOP/128
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC1P0 $IP6LC1P0/128
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface ip address $NAMELC1P1 $IP6LC1P1/128
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add ::/0 via $DEFAULTIP6 $NAMELC1P0
sudo $SFLAG $BINS/vppctl -p $PREFIX set ip6 neighbor $NAMELC1P0 $DEFAULTIP6 $MACLC1P1 static

###
echo "Loop"
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface l2 bridge loop0 13 bvi
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state loop0 up

# Check here (?)
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 10.0.0.0/28 via $IPLC1P0
sudo $SFLAG $BINS/vppctl -p $PREFIX ip route add 10.0.1.0/28 via $IPLC1P1

# Up
echo "UP"
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC1P0 up
sudo $SFLAG $BINS/vppctl -p $PREFIX set interface state $NAMELC1P1 up



#learn the MAC of the src ip
#sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static TenGigabitEthernet84/0/0 192.168.2.2 $MACLC0P0
#sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static TenGigabitEthernet84/0/1 192.168.2.4 $MACLC0P1
#sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static TenGigabitEthernet84/0/1 $IPLC1P0 90:e2:ba:cb:f5:48
#sudo $SFLAG $BINS/vppctl -p $PREFIX set ip arp static TenGigabitEthernet84/0/1 $IPLC1P1 90:e2:ba:cb:f5:49


#learn the MAC of the dst interface
sudo $SFLAG $BINS/vppctl -p $PREFIX l2fib add $MACLC1P1 13 $NAMELC1P0 static

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

 



