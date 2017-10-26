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

cd $RTE_PKTGEN

echo "***************************"
echo "Using pkt_gen: $RTE_PKTGEN"
echo "Config-script: $DPDK_CONF"
echo "Pktgen-script: $PKTGEN_SCRIPT"
echo "***************************"

ERRFILE=/tmp/err.out

for i in "${!param[@]}"; do param["$i"]=$(echo -e `grep $i $DPDK_CONF | cut -d '=' -f 2-`); done


if [[ $# -eq 0 ]] ; then
  echo 'STARTING PKTGEN WITH DEFAULT PARAMETERS' 

  sudo -E app/app/x86_64-native-linuxapp-gcc/pktgen -l ${param['main-core']},${param['workers']} -n 1 -m 2048 ${param['dev']} -- -P -T -m ${param['map']}
  #sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 12,13-16 -n 1 -w $LC0P0 -w $LC0P1 -- -P -T -m "[13-14].0,[15-16].1"
exit 1
fi

if [ "$1" == "forwarding" ]; then
	echo "NOT PATCHED"
	#sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 1,2-5 -n 1 -w $LC0P0 -w $LC0P1 -- -P -T -m "[2-3].0,[4-5].1" -f $PKTGEN_SCRIPT

else
	echo "NOT PATCHED"
	#echo "Starting pktgen with a .pkt file"
	######## NOT PATCHED! 03/04/2017, Leos ###########
    #F=`$CONFIG_DIR/dpdk_config-pktgen.sh $1`
	#sudo app/app/x86_64-native-linuxapp-gcc/pktgen -l 12,13-16 -n 1 -w $LC0P0 -w $LC0P1 -- -P -T -m "[13-14].0,[15-16].1" -f $1
fi
