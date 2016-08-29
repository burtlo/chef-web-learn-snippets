#
# Cookbook Name:: learn_the_basics_ubuntu
# Recipe:: set-up-your-own-server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

shell = node['platform'] == 'windows' ? 'ps' : nil
with_snippet_options(lesson: 'set-up-your-own-server', shell: shell) do
  include_recipe 'workstation::chefdk'
end
