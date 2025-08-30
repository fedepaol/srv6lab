#!/bin/bash
#

ip address add 10.0.0.1/32 dev lo


# Leaf - host leg
ip addr add 192.168.11.1/24 dev eth1
ip addr add 192.169.11.2/24 dev eth2
