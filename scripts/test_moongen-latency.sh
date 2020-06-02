#!/bin/bash

source $HOME/vpp-bench/scripts/config.sh
cd $MOONDIR

if [ -z "$1" ]; then
	echo "Starting Moongen 10Gbps";
	sudo ./build/MoonGen ~/vpp-bench/scripts/moongen_scripts/latency.lua 1 0 -r 10000
elif [ -z "$2" ]; then
	sudo ./build/MoonGen ~/vpp-bench/scripts/moongen_scripts/latency.lua 1 0 -r 10000
elif [ -z "$3" ]; then
	sudo ./build/MoonGen ~/vpp-bench/scripts/moongen_scripts/latency.lua 1 0 -r $1 -m $2
else
	sudo ./build/MoonGen ~/vpp-bench/scripts/moongen_scripts/latency.lua 1 0 -r $1 -m $2 -s $3
fi




echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
