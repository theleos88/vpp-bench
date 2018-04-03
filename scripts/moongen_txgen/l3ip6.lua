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

-- set addresses here
local DST_MAC		= nil -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE	= "10.0.0.10" -- actual address will be SRC_IP_BASE + random(0, flows)
local SRC_IP6_BASE	= "3311::1" -- IP6
local DST_IP		= "10.1.0.10"
local SRC_PORT		= 1234
local DST_PORT		= 319

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
	parser:option("-f --flows", "Number of flows (randomized source IP)."):default(4):convert(tonumber)
	parser:option("-s --size", "Packet size."):default(60):convert(tonumber)
	parser:option("-l --slaves", "Slaves."):default(1):convert(tonumber)
end

function master(args)
	txDev = device.config{port = args.txDev, rxQueues = args.slaves  , txQueues = args.slaves}
	rxDev = device.config{port = args.rxDev, rxQueues = 3, txQueues = 3}
	print ("Leos TX / RX = "..args.txDev.." || "..args.rxDev.." "..args.slaves.."\n")	

	device.waitForLinks()

	mg.startTask("statsSlave", txDev, rxDev, args.size, args.flows)

	for i=0,args.slaves-1 do
		mg.startTask("loadSlave", txDev:getTxQueue(i), rxDev, args.size, args.flows)
	end

	arp.startArpTask{
		-- run ARP on both ports
		{ rxQueue = rxDev:getRxQueue(2), txQueue = rxDev:getTxQueue(2), ips = RX_IP },
		-- we need an IP address to do ARP requests on this interface
		{ rxQueue = txDev:getRxQueue(2), txQueue = txDev:getTxQueue(2), ips = ARP_IP }
	}
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

function loadSlave(queue, rxDev, size, flows)
	doArp()
	local mempool = memory.createMemPool(function(buf)
		fillUdp6Packet(buf, size)
	end)
	local bufs = mempool:bufArray()
	local counter = 0
	--local baseIP = parseIPAddress(SRC_IP_BASE)
	local baseIP6 = parseIP6Address(SRC_IP6_BASE)
	while mg.running() do
		b = bufs:alloc(size)
		--clib.fill_ip6(bufs.array, 32)	-- Working, but I need to fix that 32 hardcoded
		for i, buf in ipairs(bufs) do
			local pkt = buf:getUdp6Packet()
			--clib.fill_single_ip6(buf)	-- Working, at 8.4 Mpps
			--clib.fill_rr_ip6(buf)
			pkt.ip6.dst:set(baseIP6 + counter)	-- This is really slow 
			counter = incAndWrap(counter, flows)
		end
		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums(false)
		queue:send(bufs)
	end
end

function statsSlave(txQueue, rxQueue, size, flows)
	local txCtr = stats:newDevTxCounter(txQueue, "plain")
	local rxCtr = stats:newDevRxCounter(rxQueue, "plain")
	while mg.running() do
		txCtr:update()
		rxCtr:update()
	end
	txCtr:finalize()
	rxCtr:finalize()
end

