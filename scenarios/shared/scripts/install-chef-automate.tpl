#!/bin/bash
#sudo apt-get update

echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostname

if [ ! -d ~/drop ]
  then
    mkdir ~/drop
fi
if [ ! -d ~/downloads ]
  then
    mkdir ~/downloads
fi

# Install Chef server
if [ ! $(which delivery-ctl) ]
  then
    wget -P ~/downloads https://packages.chef.io/${delivery_channel}/ubuntu/14.04/delivery_${delivery_version}-1_amd64.deb
    sudo dpkg -i ~/downloads/delivery_${delivery_version}-1_amd64.deb
    sudo delivery-ctl setup --license /tmp/automate.license --key /tmp/delivery.pem --server-url https://${chef_server_fqdn}/organizations/${chef_automate_org} --fqdn ${chef_automate_fqdn} --enterprise caffeine --configure --no-build-node
    sudo delivery-ctl create-user caffeine delivery --password insecurepassword --roles "admin" 
    # sudo delivery-ctl create-enterprise mammalia --ssh-pub-key-file=/etc/delivery/builder_key.pub
fi
