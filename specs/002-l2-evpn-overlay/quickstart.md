# Quickstart: L2 EVPN VXLAN Overlay

## Deploy

```bash
# Regenerate configs (if templates changed)
./generate.sh

# Deploy topology (includes teardown of existing)
sudo ./setup.sh
```

## Verify L2 Connectivity

```bash
# Ping between bridge ports (L2 via VXLAN)
docker exec clab-evpnsrv6-pe1 ping -c 3 -I br10 192.168.10.2
docker exec clab-evpnsrv6-pe1 ping -c 3 -I br10 192.168.10.3

# Check neighbor table (should show remote MACs)
docker exec clab-evpnsrv6-pe1 ip neigh show dev br10
```

## Verify EVPN Control Plane

```bash
# BGP EVPN summary on route reflector
docker exec clab-evpnsrv6-tor vtysh -c "show bgp l2vpn evpn summary"

# EVPN routes on PE
docker exec clab-evpnsrv6-pe1 vtysh -c "show bgp l2vpn evpn"

# VNI status
docker exec clab-evpnsrv6-pe1 vtysh -c "show evpn vni"
```

## Verify L3 via SRv6 (bridge port → RemotePE)

```bash
# Ping RemotePE VRF loopback from bridge port
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping -c 3 -I 192.168.10.1 10.10.20.1

# Verify existing SRv6 VPN still works
docker exec clab-evpnsrv6-pe1 ip vrf exec red ping 10.10.20.1
```
