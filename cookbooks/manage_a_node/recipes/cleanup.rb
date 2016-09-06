#
# Cookbook Name:: manage_a_node
# Recipe:: cleanup
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# Delete node & client

# Delete cookbook

if node['snippets']['virtualization'] == 'virtualbox'
  with_snippet_options(lesson: 'set-up-your-chef-server', step: 'cleaning-up', cwd: '~/learn-chef/chef-server') do
    snippet_execute 'vagrant-destroy' do
      command 'vagrant destroy --force'
    end
  end
end
