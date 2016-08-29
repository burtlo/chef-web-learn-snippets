#
# Cookbook Name:: workstation
# Recipe:: vagrant_ubuntu
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
version = node['products']['versions']['vagrant']['ubuntu']
local_package = "/home/vagrant/Downloads/vagrant_#{version}_x86_64.deb"

directory '/home/vagrant/Downloads'

remote_file local_package do
  source "https://releases.hashicorp.com/vagrant/#{version}/vagrant_#{version}_x86_64.deb"
  action :create
  not_if "stat #{local_package}"
end

package 'vagrant' do
  action :install
  source local_package
  provider Chef::Provider::Package::Dpkg
end
