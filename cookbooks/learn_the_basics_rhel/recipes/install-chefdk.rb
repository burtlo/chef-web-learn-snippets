#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: set-up-your-own-server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'set-up-your-own-server', shell: 'ps' if node['platform'] == 'windows') do
  include_recipe 'workstation::chefdk'
end
