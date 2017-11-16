-- v0: initial script with 3 lousy packets
-- v1: with for
-- v2: with templates and random selection (hopefully)


package.path = package.path ..";?.lua;test/?.lua;app/?.lua;"
function avg (a,b)
	local n
	
	if (a+b)%2 == 1 then
		n = a+b+1
		n = n/2
	else
		n = (a+b)/2
	end

	return math.floor(n)
end

function printdata(averg, inp, outp, noloss, rate)
    printf("SIZE: %d IN: %d OUT: %d LOST: %d NOLOSS: %.8f RATE: %.2f\n", averg, inp, outp, (outp-inp), noloss, rate);
end


function configtraffic( choice, send_p, rx_p )
    local seq_template = {}
    local seq_table = {}

    local myN=7
    for i=0,myN-1
    do
        seq_template[i] = {            -- entries can be in any order
            ["eth_dst_addr"] = "90e2:bacb:f54"..i,
            ["eth_src_addr"] = "90e2:bacb:f53"..i,
            ["ip_dst_addr"] = "10.1.0."..i,
            ["ip_src_addr"] = "20.2.0."..i.."/16",  -- the 16 is the size of the mask value
            ["sport"] = 10+i,          -- Standard port numbers
            ["dport"] = 20+i,          -- Standard port numbers            
            ["ethType"] = "ipv4",  -- ipv4|ipv6|vlan
            ["ipProto"] = "tcp",   -- udp|tcp|icmp
            ["vlanid"] = 1,          -- 1 - 4095
            ["pktSize"] = 64,     -- 64 - 1518
        };
        seq_template[myN+i] = {            -- entries can be in any order
            ["eth_dst_addr"] = "90e2:bacb:f54"..i,
            ["eth_src_addr"] = "90e2:bacb:f53"..i,
            ["ip_dst_addr"] = "30.3.0.1"..i,
            ["ip_src_addr"] = "40.4.0.1"..i.."/16",  -- the 16 is the size of the mask value
            ["sport"] = 30+i,          -- Standard port numbers
            ["dport"] = 40+i,          -- Standard port numbers            
            ["ethType"] = "ipv6",  -- ipv4|ipv6|vlan
            ["ipProto"] = "udp",   -- udp|tcp|icmp
            ["vlanid"] = 1,          -- 1 - 4095
            ["pktSize"] = 64,     -- 64 - 1518
        };
        
    end  
    
-------------------------------------
--SET PKTSIZE; RATE Here
------------------------------------

    pktgen.set(send_p,"size",64);
    pktgen.set(send_p,"rate",99);   -- FOR DARIOSET RATE HERE! UNITS of 0.4 Gbps. 1 -> 0.4 Gbps; 2 0.4*2 Gbps

    --pktgen.set_ipaddr("1", "dst", "1.1.1.11");
    --pktgen.set_mac("1", "90e2:bacb:f545");
    --pktgen.set_mac("0", "90e2:bacb:f544");
    --pktgen.set_ipaddr("0", "src", "1.1.1.12/24");

    seq_template.n = myN * 2;

    seq_table.n = 1000    
    for i=0,seq_table.n-1
    do 
       if math.random()<0.5 then
            seq_table[i] = seq_template[8]
       else
            seq_table[i] = seq_template[math.random(0,seq_template.n-1)]
       end 
       -- v3  
       pktgen.seqTable(i, "all", seq_table[i] );
    end
    -- v3 
    pktgen.set("all", "seqCnt", seq_table.n );

    --v4
    -- pktgen.seqTable(0, "all", seq_table );
    prints("seqTable", pktgen.decompile(0, "all"));
    pktgen.page("seq");
end

--------------------------------------------------
-- MODIFY CONFIGURATION HERE
--SIZES={64, 1500, 340}
--CONFIG= {"static", "roundrobin", "uniform"};
SIZES={64}
--SIZES={1500}
CONFIG= {"mixed"};
--------------------------------------------------

SECONDS=1000;
SLEEP=10*SECONDS;     --Sleep here

local file = io.open ("/tmp/dataout", "w");
io.output(file);

outputp=0
inputp=0
noloss=0
rate=0

send_p = "0"
rx_p = "1"

for i,v in pairs(SIZES) do
    for j,k in pairs(CONFIG) do
        printf("CONFIG: %s ", k);


        --pktgen.page("range");
        configtraffic(k, send_p, rx_p);
        pktgen.delay(50);

    	pktgen.start(tonumber(send_p));
    	pktgen.delay(2*SECONDS); --warmup
    	pktgen.stop(tonumber(send_p));
        pktgen.clear("all");
    	pktgen.delay(3000);

----------------------------------------------------------------------
        --start experiment

    	pktgen.start(tonumber(send_p));

        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'clear run' ");
        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'clear interfaces' ");
        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'clear hardware' ");
        --os.execute("sudo perf stat -v -p `pgrep vpp_main` -e cpu-clock,cycles,instructions,cpu/event=0x80,umask=0x2,name=icache_misses/,cpu/event=0x80,umask=0x1,name=icache_hit/ -o /tmp/perf-stat.txt &");

    	pktgen.delay(SLEEP);

    	pktgen.stop(tonumber(send_p));
        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'show run' > /tmp/show ");
        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'show interface' > /tmp/data ");
        --os.execute("/home/leos/vpp-bench/scripts/runs.sh 'show event-logger all' > /tmp/events ");    -- It always crashes
	--os.execute("sudo killall -s INT perf");

----------------------------------------------------------------------

    	pktgen.delay(3000);

        -- Some math
        outputp=(pktgen.portStats("all", "port")[tonumber(send_p)]["opackets"]);
        inputp=(pktgen.portStats("all", "port")[tonumber(rx_p)]["ipackets"]);
        noloss= 1-(outputp-inputp)/outputp;
        rate=inputp/(SLEEP*SECONDS);

        printdata(v, inputp, outputp, noloss, rate);
        pktgen.delay(1000);
        pktgen.clear("all");
    end
end

pktgen.stop("all");
io.close(file);
os.execute("sudo kill -9 $(pidof pktgen)");
