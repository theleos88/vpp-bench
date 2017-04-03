#!/bin/bash

TABLE=$CONFIG_DIR/table.dat 	#If no table is provided, this is the default

# Display usage
usage (){
	echo ""
    script=$(basename $0)
    echo "This command adds mac addresses to l2fib."
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
    sudo $SFLAG vppctl -p vpp l2fib add $i 0 $NAMELC1P0
    #echo "l2fib add $i 0 $NAMELC1P0" >> /tmp/commands
done

# This is for command batching.
#sudo $SFLAG vppctl -p vpp exec /tmp/commands