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

  powershell_script 'perform-iexplore-first-run-experience' do
    code <<-EOH
    & 'C:\\Program Files\\Internet Explorer\\iexplore.exe'
    & Stop-Process -processname iexplore
    EOH
  end
end
