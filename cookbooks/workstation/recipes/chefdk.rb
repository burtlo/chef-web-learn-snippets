#
# Cookbook Name:: workstation
# Recipe:: chefdk
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

platform = node['platform']

channel = node['products']['versions']['chefdk'][platform].split('-')[0]
version = node['products']['versions']['chefdk'][platform].split('-')[1]

case platform
when 'ubuntu', 'rhel'
  snippet_execute 'install-chefdk' do
    command "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c #{channel} -v #{version}"
    step 'install-the-chef-dk'
    trim_stdout ({ from: /^trying wget\.{3}$/, to: /Comparing checksum with sha256sum\.{3}$/ })
    not_if 'which chef'
  end
  shell = 'bash'
when 'windows'
  snippet_execute 'install-chefdk' do
    command ". { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chefdk -channel #{channel} -version #{version}"
    step 'install-the-chef-dk'
    not_if 'chef --version'
    shell 'powershell'
  end
  shell = 'powershell'
end

snippet_execute 'chef-version' do
  command "chef --version"
  step 'verify-chef-dk'
  shell shell
end

snippet_execute 'chef-verify' do
  command "chef verify"
  step 'verify-chef-dk'
  shell shell
end
