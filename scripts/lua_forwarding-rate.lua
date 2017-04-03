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


function configtraffic( choice )
    if (choice == "static") then 
        pktgen.delay(50);
        pktgen.delay(50);

    elseif (choice == "roundrobin") then
        pktgen.dst_mac("1", "start", "90e2:bacb:f545");
        pktgen.dst_mac("0", "start", "90e2:bacb:f544");

        pktgen.delay(50);
        pktgen.dst_ip("1", "start", "1.1.2.15");
        pktgen.dst_ip("1", "inc", "0.0.0.1");
        pktgen.dst_ip("1", "min", "1.1.2.15");
        pktgen.dst_ip("1", "max", "1.1.2.222");

        pktgen.delay(50);
        pktgen.src_ip("1", "start", "2.13.0.1");
        pktgen.src_ip("1", "inc", "0.0.0.1");
        pktgen.src_ip("1", "min", "2.13.0.1");
        pktgen.src_ip("1", "max", "2.13.0.64");
        pktgen.delay(50);

        -- printing range!!
        pktgen.set_range("1", "on");
        pktgen.set_range("0", "on");
        
    else
        pktgen.dst_mac("1", "start", "90e2:bacb:f545");
        pktgen.dst_mac("0", "start", "90e2:bacb:f544");

        pktgen.delay(50);
        pktgen.dst_ip("1", "start", "1.1.1.11");
        pktgen.dst_ip("1", "inc", "3.2.1.11");
        pktgen.dst_ip("1", "min", "1.1.1.11");
        pktgen.dst_ip("1", "max", "220.233.199.99");

        pktgen.delay(50);
        pktgen.src_ip("1", "start", "1.13.0.1");
        pktgen.src_ip("1", "inc", "0.0.0.13");
        pktgen.src_ip("1", "min", "1.13.0.1");
        pktgen.src_ip("1", "max", "11.13.0.64");
        pktgen.delay(50);

        -- printing range!!
        pktgen.set_range("1", "on");
        pktgen.set_range("0", "on");
    end
end

--------------------------------------------------
-- MODIFY CONFIGURATION HERE
SIZES={64, 1500, 340}
CONFIG= {"static", "roundrobin", "uniform"};
--------------------------------------------------

LEFT=64;
RIGHT=1500;
PRECISION= 0.99;
SLEEP=20000;     --Sleep here
SECONDS=SLEEP/1000;

local file = io.open ("/tmp/data", "w");
io.output(file);

outputp=0
inputp=0
noloss=0
rate=0


for i,v in pairs(SIZES) do
    for j,k in pairs(CONFIG) do
        printf("CONFIG: ", k);

    	pktgen.set("1","size",v);
        pktgen.set_ipaddr("1", "dst", "1.1.1.11");
        pktgen.set_ipaddr("1", "src", "1.1.1.12");
        pktgen.set_mac("1", "90e2:bacb:f545");
        pktgen.set_mac("0", "90e2:bacb:f544");
        pktgen.set_ipaddr("0", "src", "1.1.1.12/24");

        --pktgen.page("range");
        configtraffic(k);
        pktgen.delay(50);

    	pktgen.start(1);
    	pktgen.delay(2*SECONDS); --warmup
    	pktgen.stop(1);
        pktgen.clear("all");
    	pktgen.delay(3000);
    	pktgen.start(1);
    	pktgen.delay(SLEEP);
    	pktgen.stop(1);
    	pktgen.delay(3000);

        --prints("portRates", pktgen.portStats("all", "rate"));
        --prints("pktgen.info", pktgen.info);
        --prints("portStats", pktgen.portStats("all", "port")[0]["ipackets"]);
        outputp=(pktgen.portStats("all", "port")[1]["opackets"]);
        inputp=(pktgen.portStats("all", "port")[0]["ipackets"]);
        noloss= 1-(outputp-inputp)/outputp;
        rate=inputp/SECONDS;

        --printf("SIZE:",AVG, "IN:", inputp, "OUT:",outputp,"LOST:",outputp-inputp, "NOLOSS:", noloss, "RATE:", rate,"\n");
        printdata(v, inputp, outputp, noloss, rate);

        pktgen.delay(1000);

    	--os.execute("sudo kill -USR1 $(pidof pktgen) | grep DATATX | awk '{print $0}' 2> /tmp/test ");
        --os.execute("grep 'DATATX:' /tmp/test | awk '{print $2}' > /tmp/tmp");
        --os.execute("grep 'DATATX:' /tmp/test | awk '{print $4}' > /tmp/tmp1");
    	--os.execute("grep 'DATATX:' /tmp/test | awk '{print $6}' > /tmp/tmp2");

        pktgen.clear("all");
    end
end

pktgen.stop("all");
io.close(file);
os.execute("sudo kill -9 $(pidof pktgen)");
