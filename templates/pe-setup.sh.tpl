#!/bin/bash
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.vrf.strict_mode=1
ip link add sr0 type dummy
ip link set sr0 up
ip addr add ${LOOPBACK_V4} dev lo
ip -6 addr add ${LOOPBACK_V6} dev lo
ip -6 addr add ${SRV6_LOOPBACK} dev lo
ip addr add ${LINK_V4} dev ${ISIS_IFACE}
ip -6 addr add ${LINK_V6} dev ${ISIS_IFACE}
ip link add red type vrf table 1100
ip link add lored type dummy
ip link set lored up
ip link set lored master red
ip addr add ${VRF_LO_V4} dev lored
ip -6 addr add ${VRF_LO_V6} dev lored
ip link set red up
