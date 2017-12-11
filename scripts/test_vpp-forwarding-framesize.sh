#!/bin/bash

RESULT_FILE=$VPP_ROOT/results_leonardo.dat

###################################################
# Change here the default vector sizes or the experiments
declare -ia 'framesizes=(512 128 1024 64 4 256)'
#declare -ia 'framesizes=(256)'
declare -a 'txtype=("xc" "ip" "mix")'
declare -a 'txexp=("static" "rr" "unif")'
#declare -a 'txtype=("xc" "ip" "l2")'
###################################################

echo "Results:" > $RESULT_FILE  # Initializing Result file

#Iterating over VLIB_FRAME_SIZE and for three experiments
EXP=""

for h in "${txexp[@]}"; do

    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

    for j in "${txtype[@]}"; do

        for i in "${framesizes[@]}"; do
            vpp_change-frame-size.sh $i
            vpp_compile.sh

            if [ "$j" == "xc" ]; then
                echo "Compiling with Frame size: $i, Xconnect";
                EXP="XC"
                vpp_start-default.sh &
				sleep 20
				vpp_setup-xconnect.sh

            elif [ "$j" == "ip" ]; then
                echo "Compiling with Frame size: $i, IP 128k";
                EXP="IP-128k"
                vpp_start-default.sh &
                sleep 20
                vpp_set-linecards-address.sh
                vpp_add-ip-table.sh

            elif [ "$j" == "mix" ]; then
                echo "Compiling with Frame size: $i, L2 128k";
                EXP="L2-128k"
                vpp_start-default.sh &
				sleep 20
				vpp_setup-mixed-interfaces.sh
				vpp_add-ip-table.sh
				vpp_add-ip-table.sh ${DATASETS}/table_ip6.dat "ip6"

            else
                continue
            fi

			cd /usr/local/src/MoonGen
			sudo -E ./build/MoonGen experiments_traffic/throughput.lua 1 0 -t "$h" -c "$j" >> $RESULT_FILE
            #screen -L dpdk_start-pktgen.sh "forwarding"   #Start pktgen measuring forwarding rate
            cat /tmp/data | awk -v ts="$h" -v vs="$EXP" -v fs="$i" '{print "Exp:",vs, "Vector-size:",fs, "NoTurbo:",ts, $0 }' >> $RESULT_FILE
            cat $LOG_FILE >> $PERM_LOG

            sudo killall vpp_main
            sudo killall pktgen
            sudo rm /dev/hugepages/*
        done;
    done;
done;

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
