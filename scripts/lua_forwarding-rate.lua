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


--------------------------------------------------
-- MODIFY CONFIGURATION HERE
--SIZES={64, 1500, 340}
--CONFIG= {"static", "roundrobin", "uniform"};
SIZES={64};
CONFIG= {"static"};
--------------------------------------------------

SLEEP=20000;     --Sleep here
SECONDS=SLEEP/1000;

local file = io.open ("/tmp/data", "w");
io.output(file);

outputp=0
inputp=0
noloss=0
rate=0

send_p=	"0"
rx_p=	"1"

for i,v in pairs(SIZES) do
    for j,k in pairs(CONFIG) do
        printf("CONFIG: %s ", k);

    	pktgen.set(send_p,"size",v);
        pktgen.set_ipaddr(send_p, "dst", "1.1.1.11");
        pktgen.set_ipaddr(send_p, "src", "1.1.1.12");
        pktgen.set_mac(send_p, "90e2:bacb:f545");

        pktgen.set_mac(rx_p, "90e2:bacb:f544");
        pktgen.set_ipaddr(rx_p, "src", "1.1.1.12/24");

        --pktgen.page("range");
        pktgen.delay(50);

    	pktgen.start(0);
    	pktgen.delay(2*SECONDS); --warmup
    	pktgen.stop(0);
        pktgen.clear("all");
    	pktgen.delay(3000);
    	pktgen.start(0);
    	pktgen.delay(SLEEP);
    	pktgen.stop(0);
    	pktgen.delay(3000);

        --prints("portRates", pktgen.portStats("all", "rate"));
        --prints("pktgen.info", pktgen.info);
        --prints("portStats", pktgen.portStats("all", "port")[0]["ipackets"]);
        outputp=(pktgen.portStats("all", "port")[tonumber(send_p)]["opackets"]);
        inputp=(pktgen.portStats("all", "port")[tonumber(rx_p)]["ipackets"]);
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
