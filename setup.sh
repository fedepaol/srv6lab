#!/bin/bash
#

sudo clab deploy --reconfigure --topo poc.clab.yaml

docker exec clab-poc-pe /setup.sh
docker exec clab-poc-al /setup.sh
docker exec clab-poc-sp /setup.sh
docker exec clab-poc-bl /setup.sh
docker exec clab-poc-HOST1 /setup.sh
docker exec clab-poc-HOST2 /setup.sh
