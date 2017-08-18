#!/bin/bash

TABLE=$CONFIG_DIR/table.dat 	#If no table is provided, this is the default
PREFIX=`cat $STARTUP_CONF | grep prefix | awk '{print $2}' | xargs echo -n`

# Display usage
usage (){
	echo ""
    script=$(basename $0)
    echo "This command batches several ip route add commands to one file, then executes it."
    echo "Currently reroutes all packets to LC1P0 (next-hop: LC0P0)"
    echo "Usage:"
    echo "./$script [path-to-table]"
    echo ""
}

# Check if no parameter
if [[ $# -ne 0 ]]; then
	TABLE=$1
fi

if [ "$1" == "help" ] ; then
	usage
	exit 1
fi

echo "" > /tmp/commands$PPID
source $CONFIG_DIR/config.sh

if [ "$2" == "ip6" ] ; then
    for i in `cat $TABLE`; do
        echo "ip route add $i via $DEFAULTIP6" >> /tmp/commands$PPID
    done
else
    for i in `cat $TABLE`; do
        #echo "ip route add $i via $IPLC0P0" >> /tmp/commands$PPID
        echo "ip route add $i via $DEFAULTIP" >> /tmp/commands$PPID
    done
fi

sudo $SFLAG $BINS/vppctl -p $PREFIX exec /tmp/commands$PPID
#vppctl -p vpp exec /tmp/commands$PPID
