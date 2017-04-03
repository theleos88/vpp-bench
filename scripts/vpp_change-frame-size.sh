#!/bin/bash

FILE=$VPP_ROOT/src/vlib/node.h

# Display usage
usage (){
	script=$(basename $0)
    echo 'Help:'
    echo 'Locate the definition of VLIB_FRAME_SIZE'
    echo 'and replace with custom value.'
    echo 'Looking in $VPP_ROOT/src/vlib/node.h'
    echo ''
    echo 'Usage:'
    echo "./$script <number>"
    echo ''
    exit 1
}

# Check if at least one argument
if [[ $# -eq 0 ]] ; then
	usage
fi

# Check if not a number
number='^[0-9]+$'
if ! [[ $1 =~ $number ]] ; then
   echo "error: Not a number" >&2;
   echo ""
   usage
   exit 1
fi

# Replace frame size
sed -i "s/^\(#define VLIB_FRAME_SIZE \).*/\1$1/" $FILE
