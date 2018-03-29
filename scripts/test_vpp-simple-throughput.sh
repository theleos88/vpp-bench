#!/bin/bash

TS="$(date +%H%M_%y%m%d)"
RESULT_FILE=/home/leos/git/rawdata/moongen_tx_results/results_$TS.dat

###################################################
EXP="ip"			#Options: "xc" "ip" "mix"
TYPE="unif"			#Options: "static" "rr" "unif"
TABLE="$DATASETS/table130k.dat"
#TABLE=""
NREPS=10
###################################################

echo "Results:" > $RESULT_FILE  # Initializing Result file

# Check if at least one argument
if [[ $# -eq 2 ]] ; then
    EXP=$1
	TYPE=$2
	echo "Setting EXP to $1 and TYPE to $2"
else
	echo "Using std params. To change run test with EXP TYPE"
fi

echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

for i in `seq 1 $NREPS`; do
	sudo killall vpp_main
	sudo killall pktgen
	sudo rm /dev/hugepages/*

	vpp_start-default.sh vpp$RANDOM &
	sleep 20

	case $EXP in
	xc)
		vpp_setup-xconnect.sh
	;;

	ip)
		vpp_setup-linecards-address.sh
	    vpp_add-ip-table.sh $TABLE
	;;

	mix)
		vpp_setup-mixed-interfaces.sh
		vpp_add-ip-table.sh
		vpp_add-ip-table.sh $DATASETS/table_ip6.dat ip6
	;;

	esac


	cd $MOONDIR

	echo "TYPE: $TYPE, EXP: $EXP"
	sudo -E ./build/MoonGen $CONFIG_DIR/moongen_txgen/throughput.lua --dpdk-config=/home/leos/vpp-bench/scripts/moongen_txgen/dpdk-conf.lua  1 0 -r 10000 -t $TYPE -m $EXP >> $RESULT_FILE
	cat /tmp/dataout >> $RESULT_FILE.$TYPE.$EXP

done;

#mv $RESULT_FILE $RESULTS_DIR/result$1$2.dat
sudo killall vpp_main
sudo killall pktgen
sudo rm /dev/hugepages/*

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
