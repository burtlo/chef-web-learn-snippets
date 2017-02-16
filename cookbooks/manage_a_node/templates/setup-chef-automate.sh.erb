#!/bin/bash

chef_server_fqdn=$1

# Run setup
automate-ctl setup --license /tmp/automate.license --key /tmp/delivery.pem --server-url https://$chef_server_fqdn/organizations/4thcoffee --fqdn $(hostname) --enterprise default --configure --no-build-node

# Wait for all services to come online
until (curl --insecure -D - https://localhost/api/_status) | grep "200 OK"; do sleep 15s; done
while (curl --insecure https://localhost/api/_status) | grep "fail"; do sleep 15s; done

# Create an initial user
automate-ctl create-user default user1 --password P4ssw0rd! --roles "admin"
