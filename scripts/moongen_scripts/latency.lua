local mg     = require "moongen"
local memory = require "memory"
local device = require "device"
local ts     = require "timestamping"
local filter = require "filter"
local hist   = require "histogram"
local stats  = require "stats"
local timer  = require "timer"
local arp    = require "proto.arp"
local log    = require "log"
local ffi    = require "ffi"

-- set addresses here
local DST_MAC		= nil -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE	= "10.0.1.10" -- actual address will be SRC_IP_BASE + random(0, flows)
local DST_IP		= "10.0.1.15"
local DST_L2		= "192.168.2.2"
local SRC_PORT		= 1234
local DST_PORT		= 319
local DST_MAC_LOOP	= "90:e2:ba:cb:f5:46"
local DST_INTERFACE	= "90:e2:ba:f1:dc:4c"	-- This is specific to the testbed of werner-heisenberg

-- Experiment param
EXP_TIME = 10

local clib = ffi.load("ip6_handler/build/fill-ip6")

ffi.cdef[[
    void fill_ip6(struct rte_mbuf* mbufs[], uint32_t num_bufs);
]]

ffi.cdef[[
    void fill_single_ip6(struct rte_mbuf* mbuf);
]]

ffi.cdef[[
    void fill_rr_ip6(struct rte_mbuf* mbuf);
]]



-- answer ARP requests for this IP on the rx port
-- change this if benchmarking something like a NAT device
local RX_IP		= DST_IP
-- used to resolve DST_MAC
local GW_IP		= DST_IP
-- used as source IP to resolve GW_IP to DST_MAC
local ARP_IP	= SRC_IP_BASE

function configure(parser)
	parser:description("Generates UDP traffic and measure latencies. Edit the source to modify constants like IPs.")
	parser:argument("txDev", "Device to transmit from."):convert(tonumber)
	parser:argument("rxDev", "Device to receive from."):convert(tonumber)
	parser:option("-r --rate", "Transmit rate in Mbit/s."):default(10000):convert(tonumber)
--	parser:option("-f --flows", "Number of flows (randomized source IP)."):default(200):convert(tonumber)
	parser:option("-s --size", "Packet size."):default(60):convert(tonumber)
	parser:option("-l --slaves", "Slaves."):default(5):convert(tonumber)
--	parser:option("-t --type", "Exp type."):default("static")
	parser:option("-m --mix", "Mix traffic."):default("xc")
--	parser:option("-v --fs", "VLIB Frame size."):default(256):convert(tonumber)
end

function master(args)
	txDev = device.config{port = args.txDev, rxQueues = args.slaves-1, txQueues = args.slaves-1}
	rxDev = device.config{port = args.rxDev, rxQueues = args.slaves-1, txQueues = args.slaves-1}

	device.waitForLinks()
	rate = args.rate/3.0	--We have three transmit queues.

	mg.startTask("loadSlaveL2",  txDev:getTxQueue(0), args.size, rate)
	mg.startTask("loadSlaveIp", txDev:getTxQueue(2), args.size, rate)

	if args.mix == "mix" then
		printf ("MIX EXPERIMENT")
		mg.startTask("loadSlaveIp6",  txDev:getTxQueue(1), args.size, rate)
	else
		printf ("XC EXPERIMENT")
		mg.startTask("loadSlaveIp",  txDev:getTxQueue(1), args.size, rate)
	end

	mg.startTask("timerSlave", txDev:getTxQueue(3), rxDev:getRxQueue(3), args.size)	-- For latency
	mg.startTask("loadStats", txDev, rxDev, args.size)

	mg.waitForTasks()
end

local function fillUdpPacket(buf, len)
	buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = "90:e2:ba:cb:f5:46",	--Modified Must be the MAC LOOP
		ip4Src = SRC_IP,
		ip4Dst = "192.168.2.2", --DST_IP,	-- Changing with DEFAULT_IP or IPLC0P0 -- 19/05/2020 but in reality it should be the address at the bridge
		udpSrc = SRC_PORT,
		udpDst = DST_PORT,
		pktLength = len
	}
end

local function fillL2Packet(buf, len)
	buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = DST_INTERFACE,	-- LL| 27/05: replacing with the mac of the loop interface
		ip4Src = SRC_IP,
		ip4Dst = "1.1.1.21",  --DST_L2,
		udpSrc = SRC_PORT,
		udpDst = DST_PORT,
		pktLength = len
	}
end

local function fillUdp6Packet(buf, len)
    buf:getUdp6Packet():fill{
        ethSrc = queue,
        ethDst = "90:e2:ba:cb:f5:46",	-- LL 19/05/2020: original was l3-l2-ip6 = 46:39:46
        ip6Src = "1111::1",
        ip6Dst = "1221::1",
        udpSrc = SRC_PORT,
        udpDst = DST_PORT,
        pktLength = len
    }
end

local function doArp()
	if not DST_MAC then
		log:info("Performing ARP lookup on %s", GW_IP)
		DST_MAC = arp.blockingLookup(GW_IP, 5)
		if not DST_MAC then
			log:info("ARP lookup failed, using default destination mac address")
			return
		end
	end
	log:info("Destination mac: %s", DST_MAC)
end

function loadSlaveL2(queue, size, rate)
	queue:setRate(math.floor(rate))	-- Set tx rate
	local mempool = memory.createMemPool(function(buf)
		fillL2Packet(buf, size)
	end)
	local bufs = mempool:bufArray()

	while mg.running() do
		bufs:alloc(size)
		for i, buf in ipairs(bufs) do
			local pkt = buf:getUdpPacket()
			--pkt.ip4.dst:set(baseIP + counter)
		end
		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums()
		queue:send(bufs)
	end
end

function loadSlaveIp(queue, size, rate)
	queue:setRate(math.floor(rate))	-- Set tx rate
	local mempool = memory.createMemPool(function(buf)
		fillUdpPacket(buf, size)
	end)
	local bufs = mempool:bufArray()

	while mg.running() do
		bufs:alloc(size)
		for i, buf in ipairs(bufs) do
			local pkt = buf:getUdpPacket()
			--pkt.ip4.dst:set(baseIP + counter)
		end
		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums()
		queue:send(bufs)
	end
end

function loadSlaveIp6(queue, size, rate)
	queue:setRate(math.floor(rate))	-- Set tx rate
	local mempool = memory.createMemPool(function(buf)
		fillUdp6Packet(buf, size)
	end)
	local bufs = mempool:bufArray()

	while mg.running() do
		bufs:alloc(size)
		for i, buf in ipairs(bufs) do
			local pkt = buf:getUdpPacket()
			--pkt.ip4.dst:set(baseIP + counter)
		end
		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums()
		queue:send(bufs)
	end
end

function timerSlave(txQueue, rxQueue, size)
    if size < 84 then
        log:warn("Packet size %d is smaller than minimum timestamp size 84. Timestamped packets will be larger than load packets.", size)
        size = 84
    end
    local timestamper = ts:newUdpTimestamper(txQueue, rxQueue)
    local hist = hist:new()
    mg.sleepMillis(1000) -- ensure that the load task is running
    local counter = 0   
    local rateLimit = timer:new(0.001)
    local baseIP = parseIPAddress(SRC_IP_BASE)
    --local baseIP = parseIPAddress(DST_IP)
    while mg.running() do
        hist:update(timestamper:measureLatency(size, function(buf)
            fillUdpPacket(buf, size)
            local pkt = buf:getUdpPacket()
            pkt.ip4.src:set(baseIP+counter)
            --pkt.ip4.dst:set(baseIP+counter)
            counter = incAndWrap(counter, 100)
        end))
        rateLimit:wait()
        rateLimit:reset()
    end
    -- print the latency stats after all the other stuff
    mg.sleepMillis(300)
    hist:print()
    hist:save("histogram.csv")
end



function loadStats(txDev, rxDev, size)

	local file = io.open("/tmp/dataout", "a")
	io.output(file);

	local txCtr = stats:newDevTxCounter(txDev, "plain")
	local rxCtr = stats:newDevRxCounter(rxDev, "plain")
	mg.sleepMillis(10000) -- ensure that the load task is running
	mg.setRuntime(EXP_TIME)
	while mg.running() do
		txCtr:update()
		rxCtr:update()
	end
	rxCtr:finalize()
	txCtr:finalize()


	--log:info(green("---------------------Moongen STATS---------------------------"))

	local stats = rxCtr:getStats()
	io.write("Throughput: "..stats["avg"].."\n")
	io.flush()

	--for key,value in pairs(stats) do log:info(tostring(key) .. " - " .. tostring(value)) end

	--log:info(green("------------------------STATS--------------------------------"))
	--local rxStats = rxDev:getStats()
	--log:info("ipacktes: " .. tostring(rxStats.ipackets))
	--log:info("opacktes: " .. tostring(rxStats.opackets))
	--log:info("ibytes: " .. tostring(rxStats.ibytes))
	--log:info("obytes: " .. tostring(rxStats.obytes))
	--log:info("imissed: " .. tostring(rxStats.imissed))
	--log:info("ierrors: " .. tostring(rxStats.ierrors))
	--log:info("oerrors: " .. tostring(rxStats.oerrors))
	--log:info("rx_nombuf: " .. tostring(rxStats.rx_nombuf))
	--log:info("q_ipacktes[0]: " .. tostring(rxStats.q_ipackets[0]))
	--log:info("q_ipacktes[1]: " .. tostring(rxStats.q_ipackets[1]))
	--log:info("q_ipacktes[2]: " .. tostring(rxStats.q_ipackets[2]))
	--log:info("q_ipacktes[3]: " .. tostring(rxStats.q_ipackets[3]))

--	printf("ENDOFEXP")
	--file.write(rxCtr:printStats().."\n")
	io.close(file)

end
