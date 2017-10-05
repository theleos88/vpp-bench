CURRENT=`pwd`

all:
	@echo $(value CURRENT)

clock:
	$(shell for i in `ls -1 /tmp/binaryevent_*`; do echo "parsing $i"; python3 binary_log_read.py $i | awk 'BEGIN{getline prev}{ split(prev, fields); print prev, "DurationClk:", $6-fields[6]; prev = $0  }' > $i.parsed; done;)

clean:
	rm -f data/*
