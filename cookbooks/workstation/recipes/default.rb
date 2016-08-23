#
# Cookbook Name:: workstation
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
if node['platform_family'] == 'debian'
  apt_update 'update the apt cache' do
    action :periodic
  end
end

if node['platform_family'] == 'windows'
  include_recipe 'chocolatey'
end
