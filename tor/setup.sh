#!/bin/bash

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1

ip addr add 10.0.0.10/32 dev lo
ip -6 addr add fc00:0:10::1/128 dev lo
ip addr add 10.100.0.10/24 dev eth1
ip -6 addr add fc00:100::10/64 dev eth1
ip addr add 10.200.0.0/31 dev eth2
ip -6 addr add fc00:200::/127 dev eth2
