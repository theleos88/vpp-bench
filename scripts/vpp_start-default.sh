#!/bin/bash

echo "Preparing path"
cd $VPP_ROOT

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"

echo "VPP_ROOT in : $VPP_ROOT"
echo "Binairies in : $BINS"
echo "Plugins in : $PLUGS"

echo 'STARTING WITH DEFAULT PARAMETERS (name=vpp).'
sudo $BINS/vpp `cat $STARTUP_CONF` plugin_path $PLUGS
