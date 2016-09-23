#
# Cookbook Name:: test_your_infra_code
# Recipe:: get-set-up
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory ::File.expand_path('~/learn-chef')
directory ::File.expand_path('~/learn-chef/cookbooks')

shell = node['platform'] == 'windows' ? 'ps' : nil
with_snippet_options(lesson: 'perform-prerequisites', shell: shell) do
  include_recipe 'workstation::default'
  include_recipe 'workstation::chefdk'
end
