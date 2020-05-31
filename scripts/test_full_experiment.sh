#!/bin/bash

EXP="xc"

if [[ -z $1 ]]; then
	EXP="xc"
else
	EXP="$1"
fi


echo "*** STARTING EXPERIMENT + $EXP"

for r in `seq 500 500 10001`; do
	sudo killall vpp_main
	vpp_start-default &


	if [ $EXP == "xc" ]; then
		echo "Setup XC"
		sleep 3 && vpp_setup-xconnect.sh

	elif [ $EXP == "mix" ]; then
		echo "Setup MIX"
		sleep 3 && vpp_setup-mixed-interfaces.sh
	else
		echo "No such experiment!!"
	fi


	# Starting traffic generator
	MRATE=$(echo "$r/1.31" | bc)
	ssh leo@werner $HOME/vpp-bench/scripts/test_moongen-latency.sh $MRATE $EXP &


	# Sleep for 15 seconds: Moongen takes 32s for a 20s experiment => 12s startup + 20s experiment
	echo "Querying the data structure..."
	sleep 15 && for i in `seq 1 10`; do
		sudo killall -s SIGUSR1 vpp_main
		sleep 1
	done

	# Sleep again and kill the file
	sleep 15 && sudo killall -s SIGUSR2 vpp_main

	sudo killall vpp_main

	echo "File systems checks"
	cp /tmp/clock.dat	/tmp/clock-$EXP-$r.dat
	scp leo@werner:$MOONDIR/histogram.csv /tmp/histogram-$EXP-$r.csv



done
