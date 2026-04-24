#!/bin/bash
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1
ip link add sr0 type dummy
ip link set sr0 up
ip addr add 10.0.0.2/32 dev lo
ip -6 addr add fc00:0:2::1/128 dev lo
ip -6 addr add fd00:2::1/128 dev lo
ip addr add 10.100.0.2/24 dev eth1
ip -6 addr add fc00:100::2/64 dev eth1
ip link add red type vrf table 1100
ip link add lored type dummy
ip link set lored up
ip link set lored master red
ip addr add 10.10.2.1/32 dev lored
ip -6 addr add fc00:10:2::1/128 dev lored
ip link set red up

# L2 EVPN VXLAN overlay
ip link add br10 type bridge
ip link set br10 master red
ip link set br10 addr aa:bb:cc:00:00:02
ip addr add 192.168.10.2/24 dev br10

ip link add vni110 type vxlan local 10.0.0.2 dstport 4789 id 110 nolearning
ip link set vni110 master br10 addrgenmode none
ip link set vni110 type bridge_slave neigh_suppress on learning off
ip link set vni110 up
ip link set br10 up
