#!/bin/bash

RESULT_FILE=$VPP_ROOT/results.dat
LOG_FILE=/tmp/screenlog.0

sudo ls #Getting root privileges

echo "Results:" > $RESULT_FILE  # Initializing Result file


#Iterating over VLIB_FRAME_SIZE

    #Iterating over BUSYLOOP
#    for b in `cat $CONFIG_DIR/busyloop.dat`; do
        #activate-busyloop.sh "activate" $b
        activate-busyloop.sh "deactivate"
    	echo "Compiling with Frame size: $i, BusyLoop $b";

    	compile.sh
        start-vpp-xconnect.sh
	    #sudo $BINS/vpp `cat $VPP_ROOT/startup.conf` plugin_path $PLUGS
	    sleep 1
	    #linecard.sh

        #Dicotomic search
	    min=64
    	max=1500    #Leos, anyway we don't reach this performance
	    av=100
        mpps=1

	    step=1

        #Loop for searching the good pkt size
    	while [ $min -lt $max ]; do
        	echo "">$LOG_FILE # Initializing Pktgen log file

    	    echo "Testing with f.size $i"
		    cd /tmp/

            step=`expr $step + 1`
            av=`expr '(' "$min" + "$max" + 1 ')' / 2`
            #av=`expr $min + ($min + $max)/2`

            if [ $av -eq $max -o $av -eq $min ]; then
    			echo "FRAMESIZE-$i BUSYLOOP-$b Pktsize-$av Mpps: $mpps" >> $RESULT_FILE
                break;
            fi

	    	screen -L start-pktgen.sh $av   #Start pktgen with the average
    		RET=`tail -2 $LOG_FILE | grep "DATATX" | awk '{if ($2==$4) print $6; else print "NO"; }'`

            echo "$RET"

    		if [ "$RET" == "NO" ] ; then
                min=`expr $av`
	    	else
                mpps=`expr $RET`
                max=`expr $av`
		    fi

	    	sudo rm /dev/hugepages/*
 #       done;

    	#sudo killall vpp_main
    	sudo killall pktgen
    	sudo rm /dev/hugepages/*

done
