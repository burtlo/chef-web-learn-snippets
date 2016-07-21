#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: set-up-your-own-server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(snippet_path: File.join(snippets_root, 'learn-the-basics/rhel/set-up-your-own-server'))

channel = node['product']['versions']['chefdk'].split('-')[0]
version = node['product']['versions']['chefdk'].split('-')[1]

snippet_execute 'install-chefdk' do
  command "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c #{channel} -v #{version}"
  snippet_file 'install-the-chef-dk'
  trim_stdout ({ from: /^trying wget.+$/, to: /^Installing chefdk/ })
  not_if 'which chef'
end
