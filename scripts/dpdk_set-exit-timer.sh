#!/bin/bash

FILE=$RTE_PKTGEN/app/pktgen-main.c

# Display usage
usage (){
    script=$(basename $0)
    echo "This script adds an exit timer to dpdk."
    echo "Usage:"
    echo "./$script <activate [sleep-time] | deactivate>"
    echo ""
}

# Check if no parameter
if [[ $# -eq 0 ]] ; then
    echo 'Error, no param provided.'
    usage
    exit 1
fi

# Check if activate with custom value
if [ $1 = "activate" ]; then
	echo "Activating alarm"
	sed -i '/define ALARM/c\#define ALARM 1' $FILE

	if [ -n "$2" ]; then
		echo "Setting alarm to $2"
		sed -i "/define ALARM/c\#define ALARM $2"  $FILE
	fi

else
	echo "Deactivating alarm"
	sed -i '/define ALARM/c\ //#define ALARM ' $FILE
fi

echo "Recompiling"
cd $RTE_PKTGEN
make