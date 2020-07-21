#process
    prefix= pktgen1

#cpu
    main-core= 2
	workers= 3-4

#dpdk
    dev= -w 0000:01:00.0 -w 0000:01:00.1
    socket-mem= 1024,1024

#cores
	map= [3].0,[4].1
