#!/bin/bash
runs.sh "event-logger stop"

LOG="/tmp/log_test_vpp_elog.log"

for i in `seq 1 6`; do
	sleep 1
    sudo kill -USR1 `pidof vpp`
	sleep 2

	sudo mv /tmp/vpplog /tmp/result.$1.$2.r$3.dat.$i
	if [ $? -eq 0 ]; then
   	 	echo "$1.$2.r$3 : OK" >> $LOG
	else
   	 	echo "$1.$2.r$3 : FAIL" >> $LOG
	fi

	sleep 1

#    a='event-logger save'
#   b=" result.$1.$2.r$3.dat.$i"
#    sleep 3
#    runs.sh "$a$b"
done

