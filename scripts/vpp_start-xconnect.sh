#!/bin/bash


echo "Preparing path"
cd $VPP_ROOT

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"
PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

echo "VPP_ROOT in : $VPP_ROOT"
echo "Binairies in : $BINS"
echo "Plugins in : $PLUGS"
echo "Prefix: $PREFIX"

if [[ $# -eq 0 ]] ; then
    echo 'STARTING WITH DEFAULT PARAMETERS (name=vpp; LC0P1->LC0P0). For next Usage:'
    echo './start-vpp-xconnect <prefix> LCxPy LCwPz'
    echo 'Change x, y, w, and z to match your NIC requirements. Do not use $'
    sleep 1

#    sudo $BINS/vpp api-segment { prefix vpp gid vpp } dpdk { dev $LC1P0 dev $LC1P1 socket-mem 1024,1024 } plugin_path $PLUGS
    sudo $BINS/vpp `cat $STARTUP_CONF` plugin_path $PLUGS &
    sleep 15
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int l2 xconnect $NAMELC0P1 $NAMELC0P0
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int state $NAMELC0P0 up
    sudo $SFLAG $BINS/vppctl -p $PREFIX set int state $NAMELC0P1 up

    echo "$BINS/vppctl -p $PREFIX set int l2 xconnect $NAMELC0P1 $NAMELC0P0"
    echo "$BINS/vppctl -p $PREFIX set int state $NAMELC0P0 up"
    echo "$BINS/vppctl -p $PREFIX set int state $NAMELC0P1 up"

	echo "Done Xconnecting"
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

echo ""
echo ""

a=`awk '{for (i=1;i<=NF;i++) if ($i=="prefix") print $(i+1)}' $STARTUP_CONF`
if [ "$a" != "$1" ] ; then
	echo ""
	echo "Warning, name mismatch. Provided: $1; STARTUP_CONF: $a"
	echo ""
fi

echo "Starting vpp, $pci1, $pci2, $name1, $name2"
sudo $BINS/vpp `cat $STARTUP_CONF` plugin_path $PLUGS
sleep 2

echo "Crossconnecting, $name2 -> $name1"
sudo $SFLAG vppctl -p $1 set int l2 xconnect $name2 $name1
sudo $SFLAG vppctl -p $1 set int state $name1 up
sudo $SFLAG vppctl -p $1 set int state $name2 up

if [ -n "$debug" ]; then
    echo "Not working"
    #sudo gdb -p `ps -ef | grep vpp_main | awk '{printf $2}'`
fi
