#!/bin/bash

RESULT_FILE=$VPP_ROOT/results.dat
LOG_FILE=/tmp/screenlog.0
PERM_LOG=$VPP_ROOT/permlog.dat

###################################################
# Change here the default vector sizes or the experiments
declare -ia 'framesizes=(512 128 1024 64 4 256)'
declare -a 'txtype=("xc" "ip")'
#declare -a 'txtype=("xc" "ip" "l2")'
###################################################

echo "Results:" > $RESULT_FILE  # Initializing Result file

#Iterating over VLIB_FRAME_SIZE and for three experiments
EXP=""

for j in "${txtype[@]}"; do

    for i in "${framesizes[@]}"; do
        vpp_change-frame-size.sh $i
        vpp_compile.sh

        if [ "$j" == "xc" ]; then
            echo "Compiling with Frame size: $i, Xconnect";
            EXP="XC"
            vpp_start-xconnect.sh

        elif [ "$j" == "ip" ]; then
            echo "Compiling with Frame size: $i, IP 128k";
            EXP="IP-128k"
            vpp_start-default.sh
            vpp_set-linecards-address.sh
            vpp_add-ip-table.sh

        elif [ "$j" == "l2" ]; then
            echo "Compiling with Frame size: $i, L2 128k";
            EXP="L2-128k"
            vpp_start-default.sh
            vpp_set-linecards-address.sh
            vpp_add-l2-table.sh
        
        else
            continue
        fi

        screen -L dpdk_start-pktgen.sh "forwarding"   #Start pktgen measuring forwarding rate
        cat /tmp/data | awk -v vs="$EXP" -v fs="$i" '{print "Exp:",vs, "Vector-size:",fs, $0 }' >> $RESULT_FILE
        cat $LOG_FILE >> $PERM_LOG

        sudo killall vpp_main
        sudo killall pktgen
        sudo rm /dev/hugepages/*
    done;
done

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
