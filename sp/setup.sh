#!/bin/bash
#

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1

ip -6 addr add fc00:0000:0000:0000::6/127 dev eth1 # to al
ip -6 addr add fc00:0000:0000:0000::0/127 dev eth2 # to bl
