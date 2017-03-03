#!/bin/bash

# Addresses
export LINCS=137.194.165.4
export VPP=137.194.208.243

# Aliases
alias update-conf='svn export https://github.com/TeamRossi/vpp_dev/trunk/scripts --force /usr/local/etc/scripts'


# Linecards
export LC1P1=0000:0b:00.0
export LC1P2=0000:0b:00.1
export LC2P1=0000:84:00.0
export LC2P2=0000:84:00.1

# Router-friendly Names
export NAMELC1P1="TenGigabitEthernetb/0/0"
export NAMELC1P2="TenGigabitEthernetb/0/1"
export NAMELC2P1="TenGigabitEthernet84/0/0"
export NAMELC2P2="TenGigabitEthernet84/0/1"

# MAC addresses
# TODO

# DPDK
export RTE_SDK=/usr/local/src/dpdk-stable-16.11.1
export RTE_TARGET=x86_64-native-linuxapp-gcc