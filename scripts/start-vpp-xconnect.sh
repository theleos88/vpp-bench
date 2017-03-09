#!/bin/bash


echo "Preparing path"
cd $VPP_ROOT

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
LIBS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"


if [[ $# -eq 0 ]] ; then
    echo 'STARTING WITH DEFAULT PARAMETERS. For next Usage:'
    echo './start-vpp-xconnect <prefix> LCxPy LCwPz'
    echo 'Change x, y, w, and z to match your NIC requirements. Do not use $'
    sleep 1

    sudo $BINS/vpp api-segment { prefix vpp gid vpp } dpdk { dev $LC2P1 dev $LC2P2 socket-mem 1024,1024 } plugin_path $LIBS
    sudo $SFLAG vppctl -p vpp set int l2 xconnect $NAMELC2P2 $NAMELC2P1
    #sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p vpp set int l2 xconnect $NAMELC2P2 $NAMELC2P1
    #sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p vpp set int state $NAMELC2P1 up
    #sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p vpp set int state $NAMELC2P2 up

    exit 1
fi

if [[ $# -eq 4 ]] ; then
    echo "DEBUG MODE"
fi
debug=$4

var=$2
pci1=${!var}

var=$3
pci2=${!var}

var="NAME"$2
name1=${!var}

var="NAME"$3
name2=${!var}

echo "Starting vpp, $pci1, $pci2, $name1, $name2"
make run-release
#sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vpp api-segment { prefix $1 gid vpp } dpdk { dev $pci1 dev $pci2 socket-mem 1024,1024 }
sleep 2

echo "Crossconnecting, $name2 -> $name1"
sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p $1 set int l2 xconnect $name2 $name1
sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p $1 set int state $name1 up
sudo $VPP_ROOT/build-root/install-vpp-native/vpp/bin/vppctl -p $1 set int state $name2 up

if [ -n "$debug" ]; then
    echo "Not working"
    #sudo gdb -p `ps -ef | grep vpp_main | awk '{printf $2}'`
fi
