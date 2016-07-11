#!/bin/bash

set -e

INVENTORY="nodes_to_inv.py"

echo "Createing repository and CCP images, it may take a while..."
ansible-playbook -i $INVENTORY playbooks/ccp-build.yaml

echo "Deploying up OpenStack CCP..."
ansible-playbook -i $INVENTORY playbooks/ccp-deploy.yaml
