#!/bin/bash


START="$(sudo grep cpu10 /proc/stat)"
IDLE="$(echo ${START} | awk '{print $5}')"
SUM="$(echo ${START} | awk '{print $2+$3+$4+$5+$6+$7+$8}')"

echo $START
for i in `seq 1 10`; do
	sleep 1
	START2="$(sudo grep cpu10 /proc/stat)"
	IDLE2="$(echo ${START2} | awk '{print $5}')"
	SUM2="$(echo ${START2} | awk '{print $2+$3+$4+$5+$6+$7+$8}')"
	#echo $SUM2
	S="$(($SUM2-$SUM))"
	V="$(($IDLE2 - $IDLE))"
	bc -l <<< "scale=2; $V*100/$S"
done
echo $START2


#echo $START
#echo $IDLE

