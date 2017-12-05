#!/bin/bash

RESULT_FILE=$VPP_ROOT/results_leonardo.dat

###################################################
EXP="xc"			#Options: "ip" "mix"
TYPE="static"		#Options: "rr" "unif"
NREPS=10
###################################################

echo "Results:" > $RESULT_FILE  # Initializing Result file


echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

for i in `seq 1 $NREPS`; do
	sudo killall vpp_main
	sudo killall pktgen
	sudo rm /dev/hugepages/*

	vpp_start-default.sh &
	sleep 20
	vpp_setup-xconnect.sh

	cd /usr/local/src/MoonGen

	echo "TYPE: $TYPE, EXP: $EXP"
	sudo -E ./build/MoonGen experiments_traffic/throughput.lua 1 0 -t $TYPE -m $EXP >> $RESULT_FILE

done;

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
