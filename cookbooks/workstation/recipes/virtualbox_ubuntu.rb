#
# Cookbook Name:: workstation
# Recipe:: virtualbox_ubuntu
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
execute 'setup virtualbox apt repository' do
  command 'echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" | tee /etc/apt/sources.list.d/oracle-vbox.list'
  not_if 'stat /etc/apt/sources.list.d/oracle-vbox.list'
  notifies :run, 'execute[setup oracle public key]', :immediately
end

execute 'setup oracle public key' do
  command 'wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - && wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add - && apt-get update'
  action :nothing
  notifies :run, 'execute[install virtualbox dependencies]', :immediately
end

execute 'install virtualbox dependencies' do
  command 'apt-get install linux-headers-`uname -r` -y'
  action :nothing
  notifies :run, 'execute[install virtualbox]', :immediately
end

execute 'install virtualbox' do
  command "(apt-get install virtualbox-#{node['products']['versions']['virtualbox']['debian']} -y || apt-get -f install -y) && /sbin/vboxconfig"
  action :nothing
end
