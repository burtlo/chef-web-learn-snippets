#
# Cookbook Name:: workstation
# Recipe:: vagrant_ubuntu
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# The Chocolately Vagrant script installs vcredist, but vcredist requires --allowemptychecksum,
# which isn't provided by all versions of the Vagrant script.
chocolatey_package 'vcredist2010' do
  action :install
  options '--allowemptychecksum'
end

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

# TODO: Seems you need this for Vagrant 1.8.4. Check back later.
# https://github.com/mitchellh/vagrant/issues/7490
windows_zipfile 'c:\hashicorp\vagrant\embedded' do
  source 'https://www.rubyencoder.com/support/files/rgloader.mingw.zip'
  action :unzip
  overwrite true
  #not_if {::File.exists?('c:\hashicorp\vagrant\embedded\rgloader\loader.rb')}
end
