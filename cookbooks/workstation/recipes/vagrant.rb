#
# Cookbook Name:: workstation
# Recipe:: vagrant
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe "workstation::vagrant_#{node['platform']}"

ruby_block 'get-vagrant-version' do
  block do
    if node['platform'] == 'windows'
      cmd = powershell_out(%Q[vagrant --version])
    else
      cmd = shell_out(%Q[vagrant --version])
    end
    cmd.error!

    version = Array(cmd.stdout.strip).grep(/Vagrant (\d+\.\d+\.\d+)/) { $1 }[0]

    path = node['platform'] == 'windows' ? 'C:/vagrant/vagrant-windows.version' : '/vagrant/vagrant-ubuntu.version'
    ::File.write(path, version)
  end
end
