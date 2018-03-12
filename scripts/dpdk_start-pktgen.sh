#!/bin/bash

PKTGEN_SCRIPT=$CONFIG_DIR/lua_forwarding-rate.lua
: ${DPDK_CONF:=$CONFIG_DIR/tgdpdk.conf}

##########################
declare -A param
param["prefix"]="pippo"
param["main-core"]="1"
param["workers"]="3-4"
param["dev"]=""
param["map"]=""
#########################

#ARHG[$A]=$B

cd $RTE_PKTGEN

echo "***************************"
echo "Using pkt_gen: $RTE_PKTGEN"
echo "Config-script: $DPDK_CONF"
echo "Pktgen-script: $PKTGEN_SCRIPT"
echo "***************************"

ERRFILE=/tmp/err.out

for i in "${!param[@]}"; do param["$i"]=$(echo -e `grep $i $DPDK_CONF | cut -d '=' -f 2-`); done

if [[ $# -eq 0 ]] ; then
    echo 'STARTING PKTGEN FROM TGDPDK'
	echo "app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 ${param['dev']} -m 2048 --file-prefix ${param['prefix']} -- -P -T -m ${param['map']}"

	sudo -E app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 -m 2048 ${param['dev']} --file-prefix ${param['prefix']} -- -P -T -m ${param['map']}
#	exit 1
fi

if [ "$1" == "forwarding" ]; then
	sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 -m 2048 ${param['dev']} -- -P -T -m ${param['map']} -f $PKTGEN_SCRIPT
elif [ "$1" == "--prefix" ]; then
	sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 -m 2048 ${param['dev']} --file-prefix ${param['prefix']} -- -P -T -m ${param['map']}
	#echo " app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 -m 2048 ${param['dev']} --file-prefix $2 -- -P -T -m "${param['map']}""
else
	echo "Starting pktgen with a .pkt file"
	#sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 12,13-16 -n 1 -w $LC0P0 -w $LC0P1 -- -P -T -m "[13-14].0,[15-16].1" -f $1
fi
