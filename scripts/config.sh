#!/bin/bash

## INFO
## This config file should be sourced at the beginning of the experiments.
## You can also automatically source it through the .bashrc file
##
## Remember to set values according to your system:
##
## 1. Linecards PCI addresses
## 2. Router-friendly and Linux-friendly names
## 3. MAC and IP addresses of your linecards
## 4. VPP_ROOT, in order to switch to different versions
## 5. RTE_SDK, RTE_PKTGEN etc for the traffic generator of your choice
##
## Configuration variables and aliases are provided at the end of the file

# Linecards
export LC0P0=0000:84:00.0
export LC0P1=0000:84:00.1
export LC1P0=0000:86:00.0
export LC1P1=0000:86:00.1

# Router-friendly Names
export NAMELC0P0="TenGigabitEthernet84/0/0"
export NAMELC0P1="TenGigabitEthernet84/0/1"
export NAMELC1P0="TenGigabitEthernet86/0/0"
export NAMELC1P1="TenGigabitEthernet86/0/1"

# MAC addresses
export MACLC0P0="90:e2:ba:61:e5:10"
export MACLC0P1="90:e2:ba:61:e5:11"
export MACLC1P0="90:e2:ba:83:c9:24"
export MACLC1P1="90:e2:ba:83:c9:25"

# Linux Friendly
export DEVLC0P0="enp11s0f0"
export DEVLC0P1="enp11s0f1"
export DEVLC1P0="enp132s0f0"
export DEVLC1P1="enp132s0f1"

# IP addresses
export IPLC0P0="1.1.1.11"
export IPLC0P1="1.1.1.12"
export IPLC1P0="1.1.1.21"
export IPLC1P1="1.1.1.22"

export MACLOOP="90:e2:ba:cb:f5:46"

# Port numbers (For MoonGen)
export IDLC0P0="0"
export IDLC0P1="1"
export IDLC1P0="2"
export IDLC1P1="3"


# IP6 addresses
export IP6LC1P0="2011:2::ffff"
export IP6LC1P1="2011:3::ffff"

export IPLOOP="10.0.0.0"
export IP6LOOP="2011:1::ffff"

# Default routes
DEFAULTIP="99.99.99.99"
DEFAULTIP6="2211:2::ffff"

# VPP
#export VPP_ROOT=/usr/local/src/vpp
export VPP_ROOT=/home/leos/vppdev/vpp
#export VPP_ROOT=/home/leos/vpp

# DPDK
export RTE_SDK=/home/leos/dpdkdev/dpdk-17.02
export RTE_PKTGEN=/home/leos/dpdkdev/pktgen-dpdk-pktgen-3.1.2
export RTE_TARGET=x86_64-native-linuxapp-gcc

# Config
export CONFIG_DIR=/home/leos/vpp-bench/scripts
export DATASETS=/home/leos/vpp-bench/datasets
export PATH=$PATH:$CONFIG_DIR:$RTE_SDK/usertools:$VPP_ROOT/build-root/build-tool-native/tools
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$VPP_ROOT/build-root/install-vpp-native/vpp/include
export STARTUP_CONF=$CONFIG_DIR/startup.conf
export DPDK_CONF=$CONFIG_DIR/tgdpdk.conf
export BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
export PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
export SFLAG="env PATH=$PATH:$BINS"

# Aliases
alias show-conf="cat $CONFIG_DIR/config.sh"
alias list-scripts="ls -l $CONFIG_DIR/*.sh"
alias dpdk-setup="$RTE_SDK/usertools/dpdk-setup.sh"
alias vppctl="sudo $SFLAG $BINS/vppctl"
alias vppprefix="cat $STARTUP_CONF | grep prefix | cut -d'x' -f2 | xargs echo -n"
