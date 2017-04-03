#!/bin/bash

TABLE=$CONFIG_DIR/table.dat 	#If no table is provided, this is the default

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

echo "" > /tmp/commands
for i in `cat $TABLE`; do
   echo "ip route add $i via $IPLC0P0" >> /tmp/commands
done

sudo $SFLAG vppctl -p vpp exec /tmp/commands
