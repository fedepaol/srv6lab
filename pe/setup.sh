#!/bin/bash
#

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1

ip link add sr0 type dummy
ip link set sr0 up

# ip addr add 192.168.10.1/24 dev eth1 -> to host 1
ip -6 addr add fc00:0000:0000:0000::13/127 dev eth2
ip -6 addr add fc00:0:0:1::12/128 dev lo


ip addr add fd00:30:12::1/128 dev lo

ip link add red type vrf table 1100

# Leaf - host leg
ip link set eth1 master red
ip addr add 10.1.1.2/24 dev eth1
ip -6 addr add fc00:0:0:10::2/64 dev eth1

ip link set red up
