#
# Cookbook Name:: manage_a_node
# Recipe:: resolve-failure
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
with_snippet_options(lesson: 'resolve-a-failure')

with_snippet_options(cwd: '~/learn-chef', step: 'set-web-content-owner') do

  # Update default recipe.
  snippet_code_block 'httpd-add-web-user-err' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/recipes/default.rb'
    source_filename 'httpd-add-web-user-err.rb'
  end

  # Update metadata.
  snippet_code_block 'metadata-0-3-0' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb'
    content lazy { ::File.open(::File.expand_path('~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb')).read.sub("version '0.2.0'", "version '0.3.0'") }
  end

  # Upload your cookbook to the Chef server
  snippet_execute 'upload-0-3-0' do
    command 'knife cookbook upload learn_chef_httpd'
    not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep 'learn_chef_httpd   0.3.0'"
  end

  # knife ssh using key-based authentication
  node1 = node['nodes']['rhel']['node1']
  snippet_execute 'knife-ccr-2' do
    command lazy { node.run_state['knife_ssh_command'] }
    ignore_failure true # in fact, we expect this to fail!
    remove_lines_matching [/locale/, /#########/]
  end

  ##### RESOLVE

  # Update default recipe.
  snippet_code_block 'httpd-add-web-user-fix' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/recipes/default.rb'
    source_filename 'httpd-add-web-user-fix.rb'
  end

  # Update metadata.
  snippet_code_block 'metadata-0-3-1' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb'
    content lazy { ::File.open(::File.expand_path('~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb')).read.sub("version '0.3.0'", "version '0.3.1'") }
  end

  # Upload your cookbook to the Chef server
  snippet_execute 'upload-0-3-1' do
    command 'knife cookbook upload learn_chef_httpd'
    not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep 'learn_chef_httpd   0.3.1'"
  end

  # knife ssh using key-based authentication
  node1 = node['nodes']['rhel']['node1']
  snippet_execute 'knife-ccr-3' do
    command lazy { node.run_state['knife_ssh_command'] }
    remove_lines_matching [/locale/, /#########/]
  end

  # Confirm the result
  snippet_execute 'curl-node1-3' do
   command "curl #{node1['ip_address']}"
  end
end
