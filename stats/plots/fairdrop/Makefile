DIR?="."
F="temp_file.dat"
OUT?="DATA"
all:
	mkdir -p DATA/
#	cat $(DIR)/flowvqueue.distr.vec | awk '{print $$3, $$NF}' | sort | uniq | grep -Ev "^ " | sort -nk2 > $(OUT)/flows.dat
# The following line is considering assumed weights.
	cat $(DIR)/flowvqueue.distr.vec | awk '{print $$3, $$9}' | sort | uniq | grep -Ev "^ " | sort -nk2 > $(OUT)/flows.dat
	cat $(DIR)/flowvqueue.distr.vec | awk '{print NR-1, $$0}' > $(F)
	for i in `awk '{print $$1}' $(OUT)/flows.dat`; do grep $$i $(F) > f_$$i.dat; done

	mv *.dat DATA/

	# This is for the total throughput
	grep "RX rate" $(DIR)/flow_monitor.dat > $(OUT)/total_thput.dat

	# This is for the observed node sizes
	grep dpdk-input $(DIR)/showrun.dat  | awk '{if ($$4 != 0) print;}' | awk '{print "dpdk-input", $$NF}' > $(OUT)/nodes.dat
	grep "outpu" $(DIR)/showrun.dat  | awk '{if ($$4 > 100) print;}' | awk '{print "TX-output", $$NF}' >> $(OUT)/nodes.dat
	grep "error" $(DIR)/showrun.dat  | awk '{if ($$4 > 100) print;}' | awk '{print "Drops", $$NF}' >> $(OUT)/nodes.dat

	# This is for the per-flow throughput
	grep "Flow entry" $(DIR)/flow_monitor.dat | sed "s/^[ \t]*//" | awk -F"[ :]" '{if ($$10 > 1.0) print $$NF, $$10}' | sort -nk1 > $(OUT)/perflow.dat 
	awk 'FNR == NR { lineno[$$1] = NR; next} {print lineno[$$1], $$0;}' $(OUT)/flows.dat $(OUT)/perflow.dat | sort -k 1,1n | cut -d' ' -f2- > d && mv d $(OUT)/perflow.dat

nofd:
	# Here we only have hashes now
	grep "RX rate" $(DIR)/flow_monitor.dat > $(OUT)/total_thput.dat

	# This is for the observed node sizes
	grep dpdk-input $(DIR)/showrun.dat  | awk '{if ($$4 != 0) print;}' | awk '{print "dpdk-input", $$NF}' > $(OUT)/nodes.dat
	grep "outpu" $(DIR)/showrun.dat  | awk '{if ($$4 > 100) print;}' | awk '{print "TX-output", $$NF}' >> $(OUT)/nodes.dat
	grep "error" $(DIR)/showrun.dat  | awk '{if ($$4 > 100) print;}' | awk '{print "Drops", $$NF}' >> $(OUT)/nodes.dat

	# This is for the per-flow throughput
	grep "Flow entry" $(DIR)/flow_monitor.dat | sed "s/^[ \t]*//" | awk -F"[ :]" '{if ($$10 > 1.0) print $$NF, $$10}' | sort -nk1 > $(OUT)/perflow.dat 
	awk 'FNR == NR { lineno[$$1] = NR; next} {print lineno[$$1], $$0;}' $(OUT)/flows.dat $(OUT)/perflow.dat | sort -k 1,1n | cut -d' ' -f2- > d && mv d $(OUT)/perflow.dat


paint:
	gnuplot fairdrop.gp
	gnuplot throughput.gp
	gnuplot nodes.gp
	gnuplot perflow.gp

clean:
	rm -f DATA/*

index:
	cat $(OUT)/perflow.dat | awk 'BEGIN{sum=0; sq=0;}{ sum+=$$2; sq+= ($$2**2); }END{ print sum, sq, NR; print ( "Fairness index:", (sum**2)/(NR*sq) )}'
