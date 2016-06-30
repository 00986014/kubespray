#!/bin/bash

set -e

create_mcp_conf() {
  echo "Create mcp config"
  cat > /root/mcp.conf << EOF
[builder]
push = True
registry = "127.0.0.1:31500"

[kubernetes]
environment = "openstack"

[repositories]
skip_empty = True
EOF
}

create_resolvconf() {
  DNS_IP=`kubectl get service/kubedns --namespace=kube-system --template={{.spec.clusterIP}}`
  cat > /root/resolv.conf << EOF
search openstack.svc.cluster.local svc.cluster.local cluster.local default.svc.cluster.local svc.cluster.local cluster.local
nameserver $DNS_IP
options attempts:2
options ndots:5
EOF
}

create_registry() {
  if kubectl get pods | grep registry ; then
    echo "Registry is already running"
  else
    echo "Create registry"
    kubectl create -f registry_pod.yaml
    kubectl create -f registry_svc.yaml
  fi
}

build_images() {
  echo "Waiting for registry to start..."
  while true
  do
    STATUS=$(kubectl get pod | awk '/registry/ {print $3}')
    if [ "$STATUS" == "Running" ]
    then
      break
    fi
    sleep 1
  done
  mcp-microservices --config-file /root/mcp.conf build &> /var/log/mcp-build.log
}

hack_base_image() {
  cp /root/resolv.conf ccp/microservices-repos/ms-debian-base/docker/base/
  sed '/COPY requirements.txt/a COPY resolv.conf /etc/resolv.conf' -i ccp/microservices-repos/ms-debian-base/docker/base/Dockerfile.j2
}

create_mcp_conf
create_registry
create_resolvconf
hack_base_image
build_images
