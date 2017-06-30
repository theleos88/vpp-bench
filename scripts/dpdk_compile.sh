#!/bin/bash

# This script simply recompiles all DPDK

cd $RTE_SDK

if [ -z "$RTE_TARGET" ]; then
	echo "Please, define RTE_TARGET";
else
	make config T=$RTE_TARGET
	#make T=$RTE_TARGET
	make install T=$RTE_TARGET
fi
