#
# Cookbook Name:: workstation
# Recipe:: packer
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe "workstation::packer_#{node['platform']}"

ruby_block 'get-packer-version' do
  block do
    if node['platform'] == 'windows'
      # TBD
      cmd = powershell_out(%Q[C:\\packer --version])
    else
      cmd = shell_out(%Q[/packer --version], returns: [0,1]) # for some reason, returns 1
    end
    cmd.error!

    version = cmd.stdout.strip

    path = node['platform'] == 'windows' ? 'C:/vagrant/packer-windows.version' : '/vagrant/packer-ubuntu.version'
    ::File.write(path, version)
  end
end
