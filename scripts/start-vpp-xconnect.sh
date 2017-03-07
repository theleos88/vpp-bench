#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Usage:'
    echo './start-vpp-xconnect <prefix> LCxPy LCwPz'
    echo 'Change x, y, w, and z to match your NIC requirements. Do not use $'
    exit 1
fi

var=$2
pci1=${!var}

var=$3
pci2=${!var}

var="NAME"$2
name1=${!var}

var="NAME"$3
name2=${!var}

echo "Starting vpp, $pci1, $pci2, $name1, $name2"
sudo $VPP_ROOT/build-root/build-vpp_debug-native/vpp/bin/vpp api-segment { prefix $1 gid vpp } dpdk { dev $pci1 dev $pci2 socket-mem 1024,1024 }
sleep 4

echo "Crossconnecting, $name2 -> $name1"
sudo $VPP_ROOT/build-root/install-vpp_debug-native/vpp/bin/vppctl -p $1 set int l2 xconnect $name2 $name1
sudo $VPP_ROOT/build-root/install-vpp_debug-native/vpp/bin/vppctl -p $1 set int state $name1 up
sudo $VPP_ROOT/build-root/install-vpp_debug-native/vpp/bin/vppctl -p $1 set int state $name2 up
