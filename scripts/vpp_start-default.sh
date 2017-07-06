#!/bin/bash

echo "Preparing path"
cd $VPP_ROOT

echo "VPP_ROOT in : $VPP_ROOT"
echo "Binairies in : $BINS"
echo "Plugins in : $PLUGS"

if [[ $# -eq 1 ]] ; then
    echo "Changing Prefix with: $1"
	sed -i "s/^\(  prefix \).*/\1$1/" $STARTUP_CONF
fi

PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

echo "STARTING VPP WITH (name=$PREFIX)."
sudo $BINS/vpp `cat $STARTUP_CONF` plugin_path $PLUGS
