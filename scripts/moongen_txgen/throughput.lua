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

-- set addresses here
local DST_MAC		= nil -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE	= "10.0.0.10" -- actual address will be SRC_IP_BASE + random(0, flows)
local DST_IP		= "10.1.0.10"
local SRC_PORT		= 1234
local DST_PORT		= 319

EXP_TIME = 10

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
	parser:option("-f --flows", "Number of flows (randomized source IP)."):default(200):convert(tonumber)
	parser:option("-s --size", "Packet size."):default(60):convert(tonumber)
	parser:option("-l --slaves", "Slaves."):default(2):convert(tonumber)
	parser:option("-t --type", "Exp type."):default("static")
	parser:option("-m --mix", "Mix traffic."):default("xc")
	parser:option("-v --fs", "VLIB Frame size."):default(256):convert(tonumber)
end

function master(args)
	txDev = device.config{port = args.txDev, rxQueues = args.slaves, txQueues = args.slaves}
	rxDev = device.config{port = args.rxDev, rxQueues = args.slaves, txQueues = args.slaves}
	print ("Leos TX / RX = "..args.txDev.." || "..args.rxDev.."Type "..args.type.."\n")	

	device.waitForLinks()

	log:info("Exp: "..args.mix.." Traffic: "..args.type)

	if args.rate > 0 then
		txDev:setRate(args.rate)
	end

	for i=0,(args.slaves-1) do
		mg.startTask("loadSlave", txDev:getTxQueue(i), args.size, args.flows, args.type)
	end

	mg.startTask("loadStats", txDev, rxDev, args.size, args.flows, args.type, args.mix, args.fs)
	mg.waitForTasks()
end

local function fillUdpPacket(buf, len)
	buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = DST_MAC,
		ip4Src = SRC_IP,
		ip4Dst = DST_IP,
		udpSrc = SRC_PORT,
		udpDst = DST_PORT,
		pktLength = len
	}
end

local function fillUdp6Packet(buf, len)
    buf:getUdp6Packet():fill{
        ethSrc = queue,
        ethDst = DST_MAC,
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

function loadSlave(queue, size, flows, type)
	--doArp()
	local mempool = memory.createMemPool(function(buf)
		fillUdpPacket(buf, size)
	end)
	local bufs = mempool:bufArray()
	local counter = 0
	local baseIP = parseIPAddress(SRC_IP_BASE)

	if type == "static" then
		while mg.running() do
			bufs:alloc(size)
			for i, buf in ipairs(bufs) do
				local pkt = buf:getUdpPacket()
				pkt.ip4.dst:set(baseIP + counter)
			end
			-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
			bufs:offloadUdpChecksums()
			queue:send(bufs)
		end
	end

	if type == "rr" then
		while mg.running() do
			bufs:alloc(size)
			for i, buf in ipairs(bufs) do
				local pkt = buf:getUdpPacket()
				pkt.ip4.dst:set(baseIP + counter)
				counter = incAndWrap(counter, flows)
			end
			-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
			bufs:offloadUdpChecksums()
			queue:send(bufs)
		--	txCtr:update()
		--	rxCtr:update()
		end
	end 
	if type == "unif" then
		while mg.running() do
			bufs:alloc(size)
			for i, buf in ipairs(bufs) do
				local pkt = buf:getUdpPacket()
				pkt.ip4.dst:set(baseIP + counter)
				counter = math.random(1,10000000)
			end
			-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
			bufs:offloadUdpChecksums()
			queue:send(bufs)
		--	txCtr:update()
		--	rxCtr:update()
		end
	end

	--txCtr:finalize()
	--rxCtr:finalize()
end

function loadStats(txDev, rxDev, size, flows, exp, type, fs)

	local file = io.open("/tmp/dataout", "a")
	io.output(file);

	io.write("FS: "..fs.." EXP: "..exp.." TYPE: "..type.." ")
	mg.sleepMillis(10000) -- ensure that the load task is running
	mg.setRuntime(EXP_TIME)
	local txCtr = stats:newDevTxCounter(txDev, "plain")
	local rxCtr = stats:newDevRxCounter(rxDev, "plain")
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
