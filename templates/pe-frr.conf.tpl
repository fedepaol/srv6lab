log file /tmp/frr.log debug
debug zebra events
debug bgp zebra
debug bgp updates
debug bgp neighbor-events
interface ${ISIS_IFACE}
 ip router isis PE
 ipv6 router isis PE
${ISIS_NETWORK_TYPE_LINE}
exit
interface lo
 ip router isis PE
 ipv6 router isis PE
exit
router bgp 65500
 bgp router-id ${ROUTER_ID}
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 neighbor TOR peer-group
 neighbor TOR remote-as 65500
 neighbor TOR update-source ${BGP_UPDATE_SOURCE}
 neighbor ${PEER_ADDR} peer-group TOR
${L2EVPN_NEIGHBORS}
 segment-routing srv6
  locator MAIN
 exit
 address-family ipv4 vpn
  neighbor TOR activate
 exit-address-family
 address-family ipv6 vpn
  neighbor TOR activate
 exit-address-family
${L2EVPN_AF_BLOCK}
exit
router bgp 65500 vrf red
 bgp router-id ${ROUTER_ID}
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 sid vpn per-vrf export auto
 address-family ipv4 unicast
  network ${VRF_LO_V4}
${L2EVPN_VRF_NETWORK}
  rd vpn export ${ROUTER_ID}:2
  rt vpn both 65500:2
  export vpn
  import vpn
 exit-address-family
 address-family ipv6 unicast
  network ${VRF_LO_V6}
  rd vpn export ${ROUTER_ID}:2
  rt vpn both 65500:2
  export vpn
  import vpn
 exit-address-family
exit
router isis PE
 is-type level-1
 net ${ISIS_NET}
 topology ipv6-unicast
 log-adjacency-changes
 log-pdu-drops
 segment-routing on
 segment-routing srv6
  locator MAIN
 exit
exit
segment-routing
 srv6
  encapsulation
   source-address ${SRV6_SOURCE}
  locators
   locator MAIN
    prefix ${SRV6_PREFIX} block-len 32 node-len 16
    behavior usid
   exit
  exit
 exit
exit
end
