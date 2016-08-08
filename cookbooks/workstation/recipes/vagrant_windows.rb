#
# Cookbook Name:: workstation
# Recipe:: vagrant_ubuntu
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
chocolatey_package 'vagrant' do
  action :install
  version node['products']['versions']['vagrant']['windows']
  notifies :run, 'powershell_script[add-vagrant-to-path]', :immediately
end

powershell_script 'add-vagrant-to-path' do
  action :nothing
  code <<-EOH
  $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
  $vagrant_path = "C:\\HashiCorp\\Vagrant\\bin"
  [Environment]::SetEnvironmentVariable("PATH", "$path;$vagrant_path", "Machine")
  EOH
end
