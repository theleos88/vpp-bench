#!/bin/bash

###INFO###
#	$1 is the experiment xc or mix
#	$2 is the packet size 

EXP="xc"
PKTSIZE=1020


if [[ -z $1 ]]; then
	EXP="xc"
else
	EXP="$1"

	if [[ -z $2 ]]; then
		PKTSIZE=$2
	else
		PKTSIZE=60
	fi
fi


source ~/vpp-bench/scripts/config.sh

echo "*** STARTING EXPERIMENT + $EXP"


for r in `seq 500 500 10001`; do

	#Destroy all vpp instances and cpusets
	sudo killall vpp_main
	sudo cset set --destroy user
	sudo cset set --destroy system

	vpp_start-default.sh &

	# After starting vpp, create a shielded version of cpus and move
	sleep 1 && sudo cset shield --cpu 3,7 --kthread=on
	sudo cset proc --move `pgrep vpp_main` user

	if [ $EXP == "xc" ]; then
		echo "Setup XC"
		sleep 1 && vpp_setup-xconnect.sh

	elif [ $EXP == "mix" ]; then
		echo "Setup MIX"
		sleep 1 && vpp_setup-mixed-interfaces.sh
	else
		echo "No such experiment!!"
	fi


	# Starting traffic generator
	MRATE=$(echo "$r/1.31" | bc)
	ssh leo@werner $HOME/vpp-bench/scripts/test_moongen-latency.sh $MRATE $EXP $PKTSIZE &


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
	sudo mv /tmp/clock.dat	/tmp/clock-$EXP-$r.dat
	scp leo@werner:$MOONDIR/histogram.csv /tmp/histogram-$EXP-$r.csv

done

## Finalize:
cd /tmp/

echo "Finishing experiment"
cp histogram-* ~/data/
for i in *.dat; do cat $i | sort -nk2 | awk -f ~/vpp-bench/scripts/awk/parse.awk | awk 'NR%3 {printf("%s", $0); next}{print $0}' > ~/data/$i; done
