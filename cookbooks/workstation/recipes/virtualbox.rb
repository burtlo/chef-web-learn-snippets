#
# Cookbook Name:: workstation
# Recipe:: virtualbox
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe "workstation::virtualbox_#{node['platform']}"

ruby_block 'get-virtualbox-version' do
  block do
    if node['platform'] == 'windows'
      cmd = powershell_out(%Q[VBoxManage --version])
    else
      cmd = shell_out(%Q[VBoxManage --version])
    end
    cmd.error!

    version = cmd.stdout.strip

    path = node['platform'] == 'windows' ? 'C:/vagrant/virtualbox-windows.version' : '/vagrant/virtualbox-ubuntu.version'
    ::File.write(path, version)
  end
end
