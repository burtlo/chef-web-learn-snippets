#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: set-up-your-own-server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(snippet_path: File.join(snippets_root, 'learn-the-basics/rhel/set-up-your-own-server'))

channel = node['machine_config']['products']['chefdk']['channel']
version = node['machine_config']['products']['chefdk']['version']

snippet_execute 'install-chefdk' do
  command "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c #{channel} -v #{version}"
  snippet_file 'install-the-chef-dk'
  trim_stdout ({ from: /^trying wget\.{3}$/, to: /Comparing checksum with sha256sum\.{3}$/ })
  not_if 'which chef'
end
