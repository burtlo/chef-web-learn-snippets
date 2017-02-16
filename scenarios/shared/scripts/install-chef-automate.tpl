#!/bin/bash

apt-get update
apt-get -y install curl

# Ensure the time is up to date
apt-get -y install ntp
service ntp stop
ntpdate -s time.nist.gov
service ntp start

# Install Chef Automate
if [ ! $(which automate-ctl) ]
  then
    # Download the package
    if [ ! -d ~/downloads ]
      then
        mkdir ~/downloads
    fi
    wget -P ~/downloads https://packages.chef.io/${delivery_channel}/ubuntu/14.04/delivery_${delivery_version}-1_amd64.deb

    # Install the package
    dpkg -i ~/downloads/delivery_${delivery_version}-1_amd64.deb

    # Run setup
    automate-ctl setup --license /tmp/automate.license --key /tmp/delivery.pem --server-url https://$chef_server_fqdn/organizations/cohovineyard --fqdn $(hostname) --enterprise chordata --configure --no-build-node
    automate-ctl reconfigure

    # Wait for all services to come online
    until (curl --insecure -D - https://localhost/api/_status) | grep "200 OK"; do sleep 5m && automate-ctl restart; done
    while (curl --insecure https://localhost/api/_status) | grep "fail"; do sleep 15s; done

    # Create an initial user
    automate-ctl create-user chordata delivery --password P4ssw0rd! --roles "admin"
fi
