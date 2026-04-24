# Quickstart: PE1 as EVPN Route Reflector

## Deploy

```bash
./generate.sh
sudo ./setup.sh
```

## Verify EVPN Peering (PE1 as RR)

```bash
# PE1 should show PE2 + PE3 as l2vpn evpn neighbors
docker exec clab-evpnsrv6-pe1 vtysh -c "show bgp l2vpn evpn summary"

# PE2 should show PE1 as l2vpn evpn neighbor (NOT TOR)
docker exec clab-evpnsrv6-pe2 vtysh -c "show bgp l2vpn evpn summary"

# TOR should have NO l2vpn evpn peers
docker exec clab-evpnsrv6-tor vtysh -c "show bgp l2vpn evpn summary"
```

## Verify L2 Connectivity

```bash
# L2 ping between bridge ports
docker exec clab-evpnsrv6-pe2 ping -c 3 -I br10 192.168.10.3
docker exec clab-evpnsrv6-pe1 ping -c 3 -I br10 192.168.10.2

# Neighbor table
docker exec clab-evpnsrv6-pe2 ip neigh show dev br10
```

## Verify L3 via SRv6 (non-regression)

```bash
# Bridge port → RemotePE VRF loopback
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping -c 3 -I 192.168.10.1 10.10.20.1

# SRv6 VPN
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping 10.10.20.1
```
