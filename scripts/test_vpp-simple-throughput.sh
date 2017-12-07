#!/bin/bash

RESULT_FILE=$RESULTS_DIR/results_leonardo.dat

###################################################
EXP="xc"			#Options: "xc" "ip" "mix"
TYPE="static"		#Options: "static" "rr" "unif"
TABLE="$DATASETS/table.dat"
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


	cd /usr/local/src/MoonGen

	echo "TYPE: $TYPE, EXP: $EXP"
	sudo -E ./build/MoonGen experiments_traffic/throughput.lua 1 0 -t $TYPE -m $EXP >> $RESULT_FILE

done;

echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
