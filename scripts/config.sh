#!/bin/bash

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
export MACLC1P1="90:e2:ba:cb:f5:38"
export MACLC1P2="90:e2:ba:cb:f5:39"
export MACLC2P1="90:e2:ba:cb:f5:44"
export MACLC2P2="90:e2:ba:cb:f5:45"

export DEVLC1P1="enp11s0f0"
export DEVLC1P2="enp11s0f1"
export DEVLC2P1="enp132s0f0"
export DEVLC2P2="enp132s0f1"

# VPP
export VPP_ROOT=/usr/local/src/vpp

# DPDK
export RTE_SDK=/usr/local/src/dpdk-17.02
export RTE_PKTGEN=/usr/local/src/pktgen-dpdk-pktgen-3.1.2
export RTE_TARGET=x86_64-native-linuxapp-gcc

# Config
export CONFIG_DIR=/usr/local/etc/scripts
export PATH=$PATH:$CONFIG_DIR:$RTE_SDK/usertools
export STARTUP_CONF=$VPP_ROOT/startup.conf
export BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
export PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
export SFLAG="env PATH=$PATH:$BINS"

# Aliases
alias update-conf="svn export https://github.com/TeamRossi/vpp_dev/trunk/scripts --force /usr/local/etc/scripts && source $CONFIG_DIR/config.sh"
alias show-conf="cat $CONFIG_DIR/config.sh"
alias list-scripts="ls $CONFIG_DIR"
alias dpdk-setup="$RTE_SDK/usertools/dpdk-setup.sh"
alias vppctl="sudo $SFLAG vppctl"
