#!/bin/bash
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1
ip link add sr0 type dummy
ip link set sr0 up
ip addr add 10.0.0.20/32 dev lo
ip -6 addr add fc00:0:20::1/128 dev lo
ip -6 addr add fd00:20::1/128 dev lo
ip addr add 10.200.0.1/31 dev eth1
ip -6 addr add fc00:200::1/127 dev eth1
ip link add red type vrf table 1100
ip link add lored type dummy
ip link set lored up
ip link set lored master red
ip addr add 10.10.20.1/32 dev lored
ip -6 addr add fc00:10:20::1/128 dev lored
ip link set red up
