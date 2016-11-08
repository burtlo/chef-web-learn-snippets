#
# Cookbook Name:: workstation
# Recipe:: packer_ubuntu
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
package 'unzip'

version = node['products']['versions']['packer']['ubuntu']
local_package = "/home/vagrant/Downloads/packer_#{version}_linux_amd64.zip"

directory '/home/vagrant/Downloads'

remote_file local_package do
  source "https://releases.hashicorp.com/packer/#{version}/packer_#{version}_linux_amd64.zip"
  action :create
  not_if "stat #{local_package}"
end

execute 'extract packer' do
  command "unzip #{local_package}"
  not_if 'stat /packer'
end
