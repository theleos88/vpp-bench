#!/bin/bash

RESULT_FILE=$VPP_ROOT/results.dat
LOG_FILE=/tmp/screenlog.0

sudo ls

echo "Results:" > $RESULT_FILE  # Initializing Result file

#Iterating over VLIB_FRAME_SIZE
for i in `cat $CONFIG_DIR/trials.dat`; do
	change-frame-size.sh $i

    #Iterating over BUSYLOOP
    for b in `cat $CONFIG_DIR/busyloop.dat`; do
        activate-busyloop.sh "activate" $b

    	echo "Compiling with Frame size: $i, BusyLoop $b";
    	compile.sh

        echo "Starting VPP"        
	    sudo $BINS/vpp `cat $VPP_ROOT/startup.conf` plugin_path $PLUGS
	    sleep 1

        echo "Setup Linecards for forwarding [xconnect|l3|l2|acl]" #To add
	    linecard.sh

        #Dicotomic search - Trying to use multiple of 10
	    min=6
    	max=140    #Leos, anyway we don't reach this performance
	    av=100
        mpps=1

	    step=1

        #Loop for searching the good pkt size
    	while [ $min -lt $max ]; do

        	echo "">$LOG_FILE # Initializing Pktgen log file
    	    echo "Testing with f.size $i"

		    cd /tmp/
            step=`expr $step + 1`
            av=`expr '(' "$min" + "$max" + 1 ')' / 2 `
            val=`expr $av \* 10`

            if [ $av -eq $max -o $av -eq $min ]; then
    			echo "FRAMESIZE-$i BUSYLOOP-$b Pktsize-$val Mpps: $mpps" >> $RESULT_FILE
                break;
            fi

	    	screen -L start-pktgen.sh $val   #Start pktgen with the average
    		RET=`tail -2 $LOG_FILE | grep "DATATX" | awk '{if ($2==$4) print $6; else print "NO"; }'`

            NOLOSS=`tail -2 $LOG_FILE | grep "DATATX" | awk '{printf "%.10f",1-($2-$4)/$2 }'`
            RATE=`tail -2 $LOG_FILE | grep "DATATX" | awk '{print $6; }'`


            # (REALLY BAD) Patching the RET stuff
            r=`echo "$NOLOSS > 0.99999" | bc`
            if [ $r -eq 1 ]; then
                RET=`expr $RATE`
            else
                RET="NO"
            fi
            #END OF REALLY BAD

    		if [ "$RET" == "NO" ] ; then
                min=`expr $av`
	    	else
                mpps=`expr $RET`
                max=`expr $av`
		    fi

	    	sudo rm /dev/hugepages/*
        done;

    	sudo killall vpp_main
    	sudo killall pktgen
    	sudo rm /dev/hugepages/*

    done;
done
