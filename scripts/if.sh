#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'No parameters provided. Usage:'
    echo './if.sh <command>'
    echo 'command = [down, up]'
    exit 1
fi

for i in `seq 1 2`; do 
	for j in `seq 1 2`; 
		do a="DEVLC$i"; 
		b="P$j"; 
		c=$a$b; 
		sudo ifconfig ${!c} $1;
	done; 
done;