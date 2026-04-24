# Quickstart: EVPN SRv6 Containerlab Topology

## Prerequisites

- containerlab installed (`clab version`)
- Docker running (`docker ps`)
- FRR image available: `docker pull quay.io/frrouting/frr:10.6.0`
- SRv6 kernel support: `modprobe seg6` (Linux 4.10+)
- sudo access for containerlab

## Deploy

```bash
./setup.sh
```

Deploys topology (with teardown of any existing lab) and runs per-node setup scripts.

## Verify

### ISIS adjacencies

```bash
docker exec clab-evpnsrv6-pe1 vtysh -c "show isis neighbor"
docker exec clab-evpnsrv6-tor vtysh -c "show isis neighbor"
docker exec clab-evpnsrv6-remotepe vtysh -c "show isis neighbor"
```

### BGP sessions

```bash
docker exec clab-evpnsrv6-pe1 vtysh -c "show bgp summary"
docker exec clab-evpnsrv6-remotepe vtysh -c "show bgp summary"
```

### SRv6 VPN routes

```bash
docker exec clab-evpnsrv6-pe1 vtysh -c "show bgp ipv6 vpn"
docker exec clab-evpnsrv6-remotepe vtysh -c "show bgp ipv6 vpn"
```

### VRF connectivity (PE↔RemotePE)

```bash
# From PE1 VRF to RemotePE VRF
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping -c 3 10.10.20.1
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping6 -c 3 fc00:10:20::1

# From PE2 VRF to RemotePE VRF
docker exec clab-evpnsrv6-pe2 ip vrf exec red ping -c 3 10.10.20.1

# From PE3 VRF to RemotePE VRF
docker exec clab-evpnsrv6-pe3 ip vrf exec red ping -c 3 10.10.20.1
```

### Check VRF loopback addresses

```bash
docker exec clab-evpnsrv6-pe1 ip addr show dev lored
docker exec clab-evpnsrv6-pe2 ip addr show dev lored
docker exec clab-evpnsrv6-pe3 ip addr show dev lored
docker exec clab-evpnsrv6-remotepe ip addr show dev lored
```

## Teardown

```bash
sudo clab destroy --topo topology.clab.yaml
```

## Topology Diagram

```
                    ┌────────────┐
         ┌──────────┤  Linux     ├──────────┐
         │          │  Bridge    │          │
         │          └─────┬──────┘          │
         │                │                 │
    ┌────┴────┐     ┌─────┴────┐      ┌────┴────┐
    │   PE1   │     │   PE2    │      │   PE3   │
    │ VRF red │     │ VRF red  │      │ VRF red │
    │ SRv6    │     │ SRv6     │      │ SRv6    │
    └─────────┘     └──────────┘      └─────────┘
         │                │                 │
         │          ┌─────┴────┐            │
         └──────────┤   TOR    ├────────────┘
                    │ (transit)│
                    └─────┬────┘
                          │
                    ┌─────┴────┐
                    │ RemotePE │
                    │ VRF red  │
                    │ SRv6     │
                    └──────────┘
```

Note: PE1/PE2/PE3 and TOR all connect to the same L2 bridge. TOR has a separate point-to-point link to RemotePE.
