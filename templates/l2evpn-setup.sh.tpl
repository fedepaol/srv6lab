
# L2 EVPN VXLAN overlay
ip link add br10 type bridge
ip link set br10 master red
ip link set br10 addr ${BRIDGE_MAC}
ip addr add ${BRIDGE_PORT_IP} dev br10

ip link add vni110 type vxlan local ${VTEP_V4} dstport 4789 id 110 nolearning
ip link set vni110 master br10 addrgenmode none
ip link set vni110 type bridge_slave neigh_suppress on learning off
ip link set vni110 up
ip link set br10 up
