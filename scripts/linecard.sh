#!/bin/bash

# Create a vpp instance with prefix: vpp1
PREFIX="vpp1"

# Manage two ports of the line card1
sudo vpp api-segment {prefix $PREFIX} dpdk {dev $LC1P1 dev $LC1P2}

# Optional: add ip addresses to check ping
sudo vppctl -p vpp1 set int ip address $NAMELC1P1 192.168.2.2/24
sudo vppctl -p vpp1 set int ip address $NAMELC1P1 192.168.2.3/24

# State up
sudo vppctl -p vpp1 set interface state $NAMELC1P1 up
sudo vppctl -p vpp1 set interface state $NAMELC1P2 up

# Show for sanity check
sudo vppctl -p vpp1 show int address
