#!/bin/bash
#

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1

ip link add sr0 type dummy
ip link set sr0 up

ip address add 10.0.0.1/32 dev lo
ip -6 addr add fd00:30:13::1 dev lo

ip -6 addr add fc00:0000:0000:0000::1/127 dev eth1 # to sp

ip link add red type vrf table 1100

# Leaf - host leg
ip link set eth2 master red
ip addr add 10.2.2.2/24 dev eth2
ip -6 addr add fc00:0:0:20::2/64 dev eth2


ip link add lored type dummy
ip link set lored up
ip link set lored master red
ip -6 addr add fc00:0:0:40::2/128 dev lored
ip link set red up
