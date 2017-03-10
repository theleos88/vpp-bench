#!/bin/bash

FILE=$VPP_ROOT/src/vlib/node.h

if [[ $# -eq 0 ]] ; then
    echo 'Error, no frame size provided. Usage:'
    echo './change-frame-size.sh <number>'
    exit 1
fi

sed -i "s/^\(#define VLIB_FRAME_SIZE \).*/\1$1/" $FILE
