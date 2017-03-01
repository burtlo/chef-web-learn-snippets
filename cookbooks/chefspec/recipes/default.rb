#
# Cookbook Name:: chefspec
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

platform = node['snippets']['node_platform']

directory ::File.expand_path('~/learn-chef')
directory ::File.expand_path('~/learn-chef/cookbooks')
package 'tree'

with_snippet_options(tutorial: 'chefspec', platform: platform, virtualization: 'local', prompt_character: node['snippets']['prompt_character'], lesson: 'chefspec') do

  snippet_config "chefspec-#{platform}" do
    tutorial 'chefspec'
  end

  include_recipe 'manage_a_node::workstation'
  include_recipe 'chefspec::windows'

end
