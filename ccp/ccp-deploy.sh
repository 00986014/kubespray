#!/bin/bash

set -e

# FIXME: hardcoded roles
declare -A nodes
nodes=( \
["node2"]="openstack-controller=true"
["node3"]="openstack-controller=true"
["node4"]="openstack-controller=true"
["node5"]="openstack-compute=true"
["node6"]="openstack-compute=true"
["node7"]="openstack-compute=true"
)

create_network_conf() {
  kubectl get nodes -o go-template='{{range .items}}{{range .status.addresses}}{{if or (eq .type "ExternalIP") (eq .type "LegacyHostIP")}}{{.address}}{{print "\n"}}{{end}}{{end}}{{end}}'> /tmp/nodes
#  ( echo "network:"; i=2; for ip in `cat /tmp/nodes `; do echo -e "  node$i:\n    private:\n      iface: eth2\n      address: $ip"; pip=`echo $ip | perl -pe 's/(\d+).(\d+).1/\${1}.\${2}.0/g'`; echo -e "    public:\n      iface: eth1\n      address: $pip" ; i=$(( i+=1 )) ;done ) > /root/cluster-topology.yaml
  ( echo "network:"; i=2; for ip in `cat /tmp/nodes `; do echo -e "  node$i:\n    private:\n      address: $ip"; i=$(( i+=1 )) ; done ) > /root/cluster-topology.yaml
}

assign_node_roles() {
  for i in "${!nodes[@]}"
  do
    node=$i
    label=${nodes[$i]}
    kubectl get nodes $node --show-labels | grep -q "$label" || kubectl label nodes $node $label
  done
}

create_network_conf
assign_node_roles

kubectl delete namespace openstack && while kubectl get namespace | grep -q ^openstack ; do sleep 5; done

mcp-microservices --config-file=/root/mcp.conf deploy -t /root/cluster-topology.yaml &> /var/log/mcp-deploy.log

