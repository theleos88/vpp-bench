#!/bin/bash

FILE=$RTE_PKTGEN/app/pktgen-main.c

if [[ $# -eq 0 ]] ; then
    echo 'Error, no param provided. Usage:'
    echo './activate-alarm.sh <activate [sleep-time] |deactivate>'
    exit 1
fi


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