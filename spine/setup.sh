#!/bin/bash
#

sysctl -w net.vrf.strict_mode=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1


ip addr add 2001:db8:cafe:f00d::2/64 dev eth1
ip addr add 2001:db8:cafe:f00e::2/64 dev eth2
