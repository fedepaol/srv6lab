#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"

generate_node() {
    local node_dir="$1"
    mkdir -p "${SCRIPT_DIR}/${node_dir}"

    envsubst '${ROUTER_ID} ${ISIS_IFACE} ${ISIS_NET} ${ISIS_NETWORK_TYPE_LINE} ${BGP_UPDATE_SOURCE} ${PEER_ADDR} ${SRV6_SOURCE} ${SRV6_PREFIX} ${VRF_LO_V4} ${VRF_LO_V6} ${L2EVPN_VRF_NETWORK} ${L2EVPN_NEIGHBORS} ${L2EVPN_AF_BLOCK}' \
        < "${TEMPLATE_DIR}/pe-frr.conf.tpl" \
        > "${SCRIPT_DIR}/${node_dir}/frr.conf"

    envsubst '${LOOPBACK_V4} ${LOOPBACK_V6} ${SRV6_LOOPBACK} ${ISIS_IFACE} ${LINK_V4} ${LINK_V6} ${VRF_LO_V4} ${VRF_LO_V6}' \
        < "${TEMPLATE_DIR}/pe-setup.sh.tpl" \
        > "${SCRIPT_DIR}/${node_dir}/setup.sh"
    chmod +x "${SCRIPT_DIR}/${node_dir}/setup.sh"

    cp "${TEMPLATE_DIR}/daemons" "${SCRIPT_DIR}/${node_dir}/daemons"
    cp "${TEMPLATE_DIR}/vtysh.conf" "${SCRIPT_DIR}/${node_dir}/vtysh.conf"
}

generate_l2evpn() {
    local node_dir="$1"
    envsubst '${VTEP_V4} ${BRIDGE_PORT_IP} ${BRIDGE_MAC}' \
        < "${TEMPLATE_DIR}/l2evpn-setup.sh.tpl" \
        >> "${SCRIPT_DIR}/${node_dir}/setup.sh"
}

# PE1
export ROUTER_ID="10.0.0.1"
export LOOPBACK_V4="10.0.0.1/32"
export LOOPBACK_V6="fc00:0:1::1/128"
export SRV6_SOURCE="fd00:1::1"
export SRV6_PREFIX="fd00:1::/48"
export SRV6_LOOPBACK="fd00:1::1/128"
export LINK_V4="10.100.0.1/24"
export LINK_V6="fc00:100::1/64"
export ISIS_NET="49.0001.0000.0000.0001.00"
export ISIS_IFACE="eth1"
export ISIS_NETWORK_TYPE_LINE=""
export BGP_UPDATE_SOURCE="fc00:0:1::1"
export PEER_ADDR="fc00:0:10::1"
export VRF_LO_V4="10.10.1.1/32"
export VRF_LO_V6="fc00:10:1::1/128"
export L2EVPN_VRF_NETWORK="  network 192.168.10.0/24"
export VTEP_V4="10.0.0.1"
export BRIDGE_PORT_IP="192.168.10.1/24"
export BRIDGE_MAC="aa:bb:cc:00:00:01"
export L2EVPN_NEIGHBORS=" neighbor EVPN-CLIENTS peer-group
 neighbor EVPN-CLIENTS remote-as 65500
 neighbor EVPN-CLIENTS update-source fc00:0:1::1
 neighbor fc00:0:2::1 peer-group EVPN-CLIENTS
 neighbor fc00:0:3::1 peer-group EVPN-CLIENTS"
export L2EVPN_AF_BLOCK=" address-family l2vpn evpn
  neighbor EVPN-CLIENTS activate
  neighbor EVPN-CLIENTS route-reflector-client
  advertise-all-vni
  advertise-svi-ip
 exit-address-family"
generate_node "pe1"
generate_l2evpn "pe1"

# PE2
export ROUTER_ID="10.0.0.2"
export LOOPBACK_V4="10.0.0.2/32"
export LOOPBACK_V6="fc00:0:2::1/128"
export SRV6_SOURCE="fd00:2::1"
export SRV6_PREFIX="fd00:2::/48"
export SRV6_LOOPBACK="fd00:2::1/128"
export LINK_V4="10.100.0.2/24"
export LINK_V6="fc00:100::2/64"
export ISIS_NET="49.0001.0000.0000.0002.00"
export ISIS_IFACE="eth1"
export ISIS_NETWORK_TYPE_LINE=""
export BGP_UPDATE_SOURCE="fc00:0:2::1"
export PEER_ADDR="fc00:0:10::1"
export VRF_LO_V4="10.10.2.1/32"
export VRF_LO_V6="fc00:10:2::1/128"
export L2EVPN_VRF_NETWORK="  network 192.168.10.0/24"
export VTEP_V4="10.0.0.2"
export BRIDGE_PORT_IP="192.168.10.2/24"
export BRIDGE_MAC="aa:bb:cc:00:00:02"
export L2EVPN_NEIGHBORS=" neighbor EVPN-RR peer-group
 neighbor EVPN-RR remote-as 65500
 neighbor EVPN-RR update-source fc00:0:2::1
 neighbor fc00:0:1::1 peer-group EVPN-RR"
export L2EVPN_AF_BLOCK=" address-family l2vpn evpn
  neighbor EVPN-RR activate
  advertise-all-vni
  advertise-svi-ip
 exit-address-family"
generate_node "pe2"
generate_l2evpn "pe2"

# PE3
export ROUTER_ID="10.0.0.3"
export LOOPBACK_V4="10.0.0.3/32"
export LOOPBACK_V6="fc00:0:3::1/128"
export SRV6_SOURCE="fd00:3::1"
export SRV6_PREFIX="fd00:3::/48"
export SRV6_LOOPBACK="fd00:3::1/128"
export LINK_V4="10.100.0.3/24"
export LINK_V6="fc00:100::3/64"
export ISIS_NET="49.0001.0000.0000.0003.00"
export ISIS_IFACE="eth1"
export ISIS_NETWORK_TYPE_LINE=""
export BGP_UPDATE_SOURCE="fc00:0:3::1"
export PEER_ADDR="fc00:0:10::1"
export VRF_LO_V4="10.10.3.1/32"
export VRF_LO_V6="fc00:10:3::1/128"
export L2EVPN_VRF_NETWORK="  network 192.168.10.0/24"
export VTEP_V4="10.0.0.3"
export BRIDGE_PORT_IP="192.168.10.3/24"
export BRIDGE_MAC="aa:bb:cc:00:00:03"
export L2EVPN_NEIGHBORS=" neighbor EVPN-RR peer-group
 neighbor EVPN-RR remote-as 65500
 neighbor EVPN-RR update-source fc00:0:3::1
 neighbor fc00:0:1::1 peer-group EVPN-RR"
export L2EVPN_AF_BLOCK=" address-family l2vpn evpn
  neighbor EVPN-RR activate
  advertise-all-vni
  advertise-svi-ip
 exit-address-family"
generate_node "pe3"
generate_l2evpn "pe3"

# RemotePE
export ROUTER_ID="10.0.0.20"
export LOOPBACK_V4="10.0.0.20/32"
export LOOPBACK_V6="fc00:0:20::1/128"
export SRV6_SOURCE="fd00:20::1"
export SRV6_PREFIX="fd00:20::/48"
export SRV6_LOOPBACK="fd00:20::1/128"
export LINK_V4="10.200.0.1/31"
export LINK_V6="fc00:200::1/127"
export ISIS_NET="49.0001.0000.0000.0020.00"
export ISIS_IFACE="eth1"
export ISIS_NETWORK_TYPE_LINE=" isis network point-to-point"
export BGP_UPDATE_SOURCE="fc00:0:20::1"
export PEER_ADDR="fc00:0:10::1"
export VRF_LO_V4="10.10.20.1/32"
export VRF_LO_V6="fc00:10:20::1/128"
export L2EVPN_VRF_NETWORK=""
export L2EVPN_NEIGHBORS=""
export L2EVPN_AF_BLOCK=""
generate_node "remotepe"

# Copy shared configs to TOR
cp "${TEMPLATE_DIR}/daemons" "${SCRIPT_DIR}/tor/daemons"
cp "${TEMPLATE_DIR}/vtysh.conf" "${SCRIPT_DIR}/tor/vtysh.conf"
chmod +x "${SCRIPT_DIR}/tor/setup.sh"

echo "Generated configs for pe1, pe2, pe3, remotepe. TOR uses hand-written configs."
