#!/bin/bash

echo "Preparing path"
cd $VPP_ROOT

echo "VPP_ROOT in : $VPP_ROOT"
echo "Binairies in : $BINS"
echo "Plugins in : $PLUGS"

echo 'STARTING WITH DEFAULT PARAMETERS (name=vpp).'
sudo $BINS/vpp `cat $STARTUP_CONF` plugin_path $PLUGS
