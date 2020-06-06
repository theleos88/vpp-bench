#!/bin/bash

FILE=$CONFIG_DIR/startup.conf

# Display usage
usage (){
	script=$(basename $0)
    echo 'Help:'
    echo 'Locate the definition of queue size'
    echo 'and replace with custom value.'
    echo "Looking in $FILE"
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
sed -i "s/^\(num-rx-desc \).*/\1$1/" $FILE
