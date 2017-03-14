#!/bin/bash

RESULT_FILE=$VPP_ROOT/results.dat
LOG_FILE=/tmp/screenlog.0

sudo ls #Getting root privileges

echo "Results:" > $RESULT_FILE  # Initializing Result file


#Iterating over VLIB_FRAME_SIZE
for i in `cat $CONFIG_DIR/trials.dat`; do
	change-frame-size.sh $i


    #Iterating over BUSYLOOP
    for b in `cat $CONFIG_DIR/busyloop.dat`; do
        activate-busyloop.sh "deactivate" $b
    	echo "Compiling with Frame size: $i, BusyLoop $b";

    	compile.sh
	    sudo $BINS/vpp `cat $VPP_ROOT/startup.conf` plugin_path $PLUGS
	    sleep 1
	    linecard.sh

        #Dicotomic search - Trying to use multiple of 10
	    min=6
    	max=140    #Leos, anyway we don't reach this performance
	    av=100
        mpps=1

	    step=1

        #Loop for searching the good pkt size
#    	while [ $min -lt $max ]; do
        for val in `seq 70 25 1100`; do
        	echo "">$LOG_FILE # Initializing Pktgen log file

    	    echo "Testing with f.size $i"
		    cd /tmp/

            step=`expr $step + 1`

	    	screen -L start-pktgen.sh $val   #Start pktgen with the average
    		RET=`tail -2 $LOG_FILE | grep "DATATX" | awk '{print $2,$4,$6; }'`

   			echo "FRAMESIZE-$i BUSYLOOP-$b Pktsize-$val Loss/Mpps: $RET " >> $RESULT_FILE

	    	sudo rm /dev/hugepages/*
        done;

    	sudo killall vpp_main
    	sudo killall pktgen
    	sudo rm /dev/hugepages/*

    done;
done
