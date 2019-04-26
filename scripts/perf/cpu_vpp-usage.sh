   #!/bin/bash
    # by Paul Colby (http://colby.id.au), no rights reserved ;)

    PREV_TOTAL=0
    PREV_IDLE=0

    while true; do
      # Get the total CPU statistics, discarding the 'cpu ' prefix.
      CPU=(`sed -n 's/^cpu10\s//p' /proc/stat`)
      IDLE=${CPU[3]} # Just the idle CPU time.

      # Calculate the total CPU time.
      TOTAL=0
      for VALUE in "${CPU[@]}"; do
        let "TOTAL=$TOTAL+$VALUE"
      done

      # Calculate the CPU usage since we last checked.
      let "DIFF_IDLE=$IDLE-$PREV_IDLE"
      let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
      let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
      echo -en "\rCPU: $DIFF_USAGE%  \b\b"

      # Remember the total and idle CPU times for the next check.
      PREV_TOTAL="$TOTAL"
      PREV_IDLE="$IDLE"

      # Wait before checking again.
      sleep 1
    done

### OLD VERSION WITH AWK
#START="$(sudo grep cpu10 /proc/stat)"
#IDLE="$(echo ${START} | awk '{print $5}')"
#SUM="$(echo ${START} | awk '{print $2+$3+$4+$5+$6+$7+$8}')"

#echo $START
#for i in `seq 1 10`; do
#	sleep 1
#	START2="$(sudo grep cpu10 /proc/stat)"
#	IDLE2="$(echo ${START2} | awk '{print $5}')"
#	SUM2="$(echo ${START2} | awk '{print $2+$3+$4+$5+$6+$7+$8}')"
#	#echo $SUM2
#	S="$(($SUM2-$SUM))"
#	V="$(($IDLE2 - $IDLE))"
#	bc -l <<< "scale=2; $V*100/$S"
#done
#echo $START2

#echo $START
#echo $IDLE

