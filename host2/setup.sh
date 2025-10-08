#!/bin/bash
#

ip addr add 10.2.2.1/24 dev eth1
ip -6 addr add fc00:0:0:20::1/64 dev eth1

ip r del default 2>/dev/null || true
ip r add default via 10.2.2.2
ip -6 r del default 2>/dev/null || true
ip -6 r add default via fc00:0:0:20::2
