#
# Cookbook Name:: manage_a_node
# Recipe:: upload-cookbook
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Ensure no versions of this cookbook are on the Chef server.
execute 'ensure-knife-cookbook-delete-learn_chef_httpd' do
  command 'knife cookbook delete learn_chef_httpd --all --yes --config ~/learn-chef/.chef/knife.rb'
  only_if 'knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep learn_chef_httpd'
end

# Ensure cookbook does not exist locally.
directory ::File.expand_path('~/learn-chef/cookbooks') do
  action :delete
  recursive true 
end

with_snippet_options(lesson: 'upload-a-cookbook', cwd: '~/learn-chef')

# 1. Create cookbooks directory

with_snippet_options(step: 'DUNNO10') do

  snippet_execute 'mkdir-cookbooks' do
    command 'mkdir ~/learn-chef/cookbooks'
    not_if 'stat ~/learn-chef/cookbooks'
  end

  snippet_execute 'cd-cookbooks' do
    command 'cd ~/learn-chef/cookbooks'
  end

end

# 1. Get cookbook from github

with_snippet_options(step: 'DUNNO11', cwd: '~/learn-chef/cookbooks') do

  snippet_execute 'git-clone-learn_chef_httpd' do
    command 'git clone https://github.com/learn-chef/learn_chef_httpd.git'
    not_if 'stat ~/learn-chef/cookbooks/learn_chef_httpd'
  end

end

# Upload your cookbook to the Chef server

with_snippet_options(step: 'DUNNO12') do

  snippet_execute 'knife-cookbook-upload-learn_chef_httpd' do
    command 'knife cookbook upload learn_chef_httpd'
    not_if 'knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep learn_chef_httpd'
  end

  snippet_execute 'knife-cookbook-list' do
    command 'knife cookbook list'
  end

end
