// always include rte_config.h, almost all DPDK headers depend it
// (but almost none of them include it themselves...)
#include <rte_config.h>
#include <rte_mbuf.h>
#include <rte_ether.h>
#include <rte_ip.h>

#include <stdlib.h>

uint8_t IP_SRC[]=  {0x11, 0x12, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1};
uint8_t IP_DST[]=  {0x22, 0x32, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2};

uint8_t cnt = 0;



// you can do everything DPDK can do from here, all libraries are available
// here we just modify some packets and let libmoon handle IO
// you could also handle the whole main loop here, however, that is unnecessarily complex
void fill_single_ip6(struct rte_mbuf* mbuf) {
	/* Handle IPv6 headers.*/
		uint8_t *pkt = rte_pktmbuf_mtod(mbuf, uint8_t*);
		//struct ether_hdr *eth = (struct ether_hdr *)(pkt);
		//eth->ether_type = ETHER_TYPE_IPv6;

		pkt+= (sizeof(struct ether_hdr));
		struct ipv6_hdr *ipv6 = (struct ipv6_hdr *)(pkt);

		ipv6->dst_addr[15] = (rand()%14)+1;

		//memcpy(ipv6->src_addr, IP_SRC, 16);
		//memcpy(ipv6->dst_addr, IP_DST, 16);

		//ipv6_hdr = rte_pktmbuf_mtod_offset(m, struct ipv6_hdr *, sizeof(struct ether_hdr));
}


void fill_rr_ip6(struct rte_mbuf* mbuf) {
	/* Handle IPv6 headers.*/
		uint8_t *pkt = rte_pktmbuf_mtod(mbuf, uint8_t*);
		pkt+= (sizeof(struct ether_hdr));

		struct ipv6_hdr *ipv6 = (struct ipv6_hdr *)(pkt);

		//ipv6->proto = IPPROTO_UDP;

		//Errors !! 
		//ipv6->src_addr = IP_SRC;
		//ipv6->dst_addr = IP_DST;

		ipv6->dst_addr[15] = ((++cnt)%15)+1;
}


void fill_ip6(struct rte_mbuf* mbufs[], uint32_t num_bufs) {
	/* Handle IPv6 headers.*/

	//dst_port = get_ipv6_dst_port(ipv6_hdr, portid,RTE_PER_LCORE(lcore_conf)->ipv6_lookup_struct);
	//if (dst_port >= RTE_MAX_ETHPORTS || (enabled_port_mask & 1 << dst_port) == 0) dst_port = portid;

	for (uint32_t i = 0; i < num_bufs; i++) {

		uint8_t *pkt = rte_pktmbuf_mtod(mbufs[i], uint8_t*);
		pkt+= (sizeof(struct ether_hdr));

		struct ipv6_hdr *ipv6 = (struct ipv6_hdr *)(pkt);

		ipv6->dst_addr[15] = (rand()%14)+1;
		//memcpy(ipv6->src_addr, IP_SRC, 16);
		//memcpy(ipv6->dst_addr, IP_DST, 16);


		//ipv6_hdr = rte_pktmbuf_mtod_offset(m, struct ipv6_hdr *, sizeof(struct ether_hdr));
		//*(uint64_t *)&eth_hdr->d_addr = dest_eth_addr[dst_port];

		/*
		swap source and destination MAC
		uint16_t tmp1 = pkt[0];
		uint16_t tmp2 = pkt[1];
		uint16_t tmp3 = pkt[2];
		pkt[0] = pkt[3];
		pkt[1] = pkt[4];
		pkt[2] = pkt[5];
		pkt[3] = tmp1;
		pkt[4] = tmp2;
		pkt[5] = tmp3;
		*/
	}
}

