#!/bin/bash

FILE=$VPP_ROOT/src/vnet/ip/ip4_input.c

if [[ $# -eq 0 ]] ; then
    echo 'Error, no param provided. Usage:'
    echo './activate-busyloop.sh <activate <num> | deactivate>'
    exit 1
fi

if [ $1 == "activate" ] && [ -z $2 ] ; then
	echo "Activate without a number. Please provide a busy loop"
	exit 1
fi

if [ $1 = "activate" ]; then
	echo "Activating Busyloop with $2"
	sed -i "/define BUSYLOOP/c\#define BUSYLOOP $2" $FILE

elif [ $1 = "deactivate" ]; then
	echo "Deactivating busyloop"
	sed -i '/define BUSYLOOP/c\ //#define BUSYLOOP ' $FILE
fi


#echo "Recompiling"
#cd $VPP_ROOT
#make build-release