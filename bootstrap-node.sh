#!/bin/bash
echo node > /var/tmp/role

# Packages
sudo apt-get --yes update
sudo apt-get --yes upgrade
sudo apt-get --yes install screen vim telnet tcpdump python-pip

# Pip
sudo pip install kpm

# SSH
sudo rm -rf /root/.ssh
sudo mv ~vagrant/ssh /root/.ssh
sudo rm -f /root/.ssh/id_rsa*
sudo chown -R root: /root/.ssh

