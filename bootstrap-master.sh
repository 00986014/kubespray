#!/bin/bash
echo master > /var/tmp/role

sudo apt-get --yes update
sudo apt-get --yes upgrade
sudo apt-get --yes install ansible git screen
sudo git clone https://github.com/kubespray/kargo /root/kargo

sudo rm -rf /root/.ssh
sudo mv ~vagrant/ssh /root/.ssh
sudo echo -e 'Host 10.210.*\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null' >> /root/.ssh/config
sudo chown -R root: /root/.ssh
