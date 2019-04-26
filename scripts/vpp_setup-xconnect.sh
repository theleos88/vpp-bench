#!/bin/bash


echo "Preparing path"
cd $VPP_ROOT

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"
#PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`
PREFIX=`cat $STARTUP_CONF | grep cli-listen | awk '{print $2}' | xargs echo -n`

if [[ $# -eq 0 ]] ; then
    echo 'STARTING WITH DEFAULT PARAMETERS (Bidirectional LC0P1<->LC0P0). For next Usage:'

    if [[ $EUID -ne 0 ]]; then
      sudo $SFLAG $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P1 $NAMELC0P0
      sudo $SFLAG $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P0 $NAMELC0P1
      sudo $SFLAG $BINS/vppctl -s $PREFIX set int state $NAMELC0P0 up
      sudo $SFLAG $BINS/vppctl -s $PREFIX set int state $NAMELC0P1 up
    else
      $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P1 $NAMELC0P0
      $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P0 $NAMELC0P1
      $BINS/vppctl -s $PREFIX set int state $NAMELC0P0 up
      $BINS/vppctl -s $PREFIX set int state $NAMELC0P1 up
    fi

	echo "Done Xconnecting"
    exit 1
fi
