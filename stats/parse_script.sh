#!/bin/bash

for i in `seq 1 1`;
	do echo "parsing $i";
	python3 binary_log_read.py /tmp/binaryevent_$i | awk 'BEGIN{getline prev}{ split(prev, fields); print prev, "DurationClk:", $4-fields[4]; prev = $0  }' > /tmp/parsed_$i;
done;
