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
  include_recipe 'manage_a_node::upload-cookbook'
  include_recipe 'manage_a_node::bootstrap-update-resolve'

  # Write config files.
  node['nodes'].each do |n|
    platform = n['platform']
    platform_display_name = case platform
    when 'rhel'
      'CentOS 7.2'
    when 'ubuntu'
      'Ubuntu 14.04'
    when 'windows'
      "Windows Server 2012 R2"
    end
    name = n['name']
    snippet_config "manage-a-node-#{platform}" do
      tutorial 'manage-a-node'
      platform platform
      variables lazy {
        ({
          node_platform: platform,
          chef_client_version: ::File.read("tmp/#{name}-chef-client-version").strip,
          node_display_name: platform_display_name
        })
      }
    end
  end
end
