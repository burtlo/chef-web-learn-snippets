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
if [ ! $(which chef-server-ctl) ]
  then
    wget -P ~/downloads https://packages.chef.io/${server_channel}/ubuntu/14.04/chef-server-core_${server_version}-1_amd64.deb
    sudo dpkg -i ~/downloads/chef-server-core_${server_version}-1_amd64.deb
    echo "data_collector[\"root_url\"] = \"${server_fqdn}/data-collector/v0/\"" | sudo tee -a /etc/opscode/chef-server.rb
    echo "data_collector[\"token\"] = \"93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506\"" | sudo tee -a /etc/opscode/chef-server.rb
    sudo chef-server-ctl reconfigure
    sudo chef-server-ctl user-create admin Bob Admin admin@4thcoffee.com insecurepassword --filename ~/drop/admin.pem
    #sudo chef-server-ctl org-create 4thcoffee "Fourth Coffee, Inc." --association_user admin --filename 4thcoffee-validator.pem
fi

# Configure push jobs
if [ ! $(which opscode-push-jobs-server-ctl) ]
  then
    wget -P ~/downloads https://packages.chef.io/${push_jobs_channel}/ubuntu/14.04/opscode-push-jobs-server_${push_jobs_version}-1_amd64.deb
    sudo chef-server-ctl install opscode-push-jobs-server --path ~/downloads/opscode-push-jobs-server_${push_jobs_version}-1_amd64.deb
    sudo chef-server-ctl reconfigure
    sudo opscode-push-jobs-server-ctl reconfigure
fi

# Create delivery user and organization
if [ ! $(sudo chef-server-ctl user-list | grep delivery) ]
  then
    sudo chef-server-ctl user-create delivery Delivery Admin delivery@4thcoffee.com insecurepassword --filename ~/drop/delivery.pem
    sudo chef-server-ctl org-create 4thcoffee 'Fourth Coffee, Inc.' --filename 4thcoffee-validator.pem -a delivery
fi
