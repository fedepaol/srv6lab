# EVPN SRv6 Containerlab

An EVPN + SRv6 lab using [containerlab](https://containerlab.dev) and FRR 10.6.0.

## Topology

```
              +---------+
              |   TOR   |
              | .10     |
              +----+----+
                   |  eth2 (p2p)
     evpnsrv6-br  |         +----------+
    +----+--------+------+  | RemotePE |
    |    |        |      |  | .20      |
  +---+ +---+ +---+     +--+----------+
  |PE1| |PE2| |PE3|
  | .1| | .2| | .3|
  +---+ +---+ +---+
   br10  br10  br10
```

## Features

- **ISIS** underlay (level-1, IPv6 unicast topology)
- **SRv6** with uSID for L3VPN (VRF `red`) across all PEs
- **EVPN VXLAN** L2 overlay between PE1, PE2, PE3 (VNI 110, bridge `br10`)
- **PE1** acts as **route reflector** for l2vpn evpn (PE2/PE3 as clients)
- **TOR** acts as route reflector for ipv4/ipv6 vpn only

## BGP Peer Groups

| Peer Group | Used On | Purpose |
|------------|---------|---------|
| TOR | All PEs | ipv4/ipv6 vpn sessions to TOR route reflector |
| EVPN-CLIENTS | PE1 | l2vpn evpn RR clients (PE2, PE3) |
| EVPN-RR | PE2, PE3 | l2vpn evpn session to PE1 route reflector |
| CLIENTS | TOR | ipv4/ipv6 vpn RR clients (all PEs) |

## Quick Start

```bash
./generate.sh        # generate PE configs from templates
sudo ./setup.sh      # deploy topology + configure nodes
```

## Validation

```bash
# EVPN peering
docker exec clab-evpnsrv6-pe1 vtysh -c "show bgp l2vpn evpn summary"

# L2 ping
docker exec clab-evpnsrv6-pe2 ping -c 3 -I br10 192.168.10.3

# L3 via SRv6
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping 10.10.20.1
```
