#!/bin/bash


echo "Preparing path"
cd $VPP_ROOT

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"
PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

if [[ $# -eq 0 ]] ; then
    echo 'STARTING WITH DEFAULT PARAMETERS (name=vpp; LC0P1->LC0P0). For next Usage:'
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int l2 xconnect $NAMELC1P1 $NAMELC1P0
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int state $NAMELC1P0 up
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int state $NAMELC1P1 up

	echo "Done Xconnecting"
    exit 1
fi
