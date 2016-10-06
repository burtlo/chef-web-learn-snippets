#
# Cookbook Name:: manage_a_node
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
with_snippet_options(
  tutorial: 'manage-a-node',
  platform: node['snippets']['node_platform'],
  virtualization: node['snippets']['virtualization'], # TODO: Change to 'environment'
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe 'manage_a_node::workstation'
  include_recipe 'manage_a_node::chef-server'
  include_recipe 'manage_a_node::upload-bootstrap-update-resolve'
end
