#!/bin/bash
#

sysctl -w net.vrf.strict_mode=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1


ip address add 10.0.0.1/32 dev lo
ip addr add  fd00:0:1::1/128 dev lo
ip addr add 2001:db8:cafe:f00d::1/64 dev eth1

ip link add red type vrf table 1100

# Leaf - host leg
ip link set eth2 master red
ip addr add 192.168.10.2/24 dev eth2

ip link set red up
