#
# Cookbook Name:: manage_a_node
# Recipe:: upload-cookbook
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

nodes = node['nodes']

# Ensure no versions of this cookbook are on the Chef server.
nodes.each do |n|
  cookbook = n['cookbook']
  execute "ensure-knife-cookbook-delete-#{cookbook}" do
    command "knife cookbook delete #{cookbook} --all --yes --config ~/learn-chef/.chef/knife.rb"
    only_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook}"
  end
end

# Ensure cookbooks do not exist locally.
directory ::File.expand_path('~/learn-chef/cookbooks') do
  action :delete
  recursive true
end

nodes.each do |n|
  cookbook = n['cookbook']
  with_snippet_options(platform: n['platform'], lesson: 'upload-a-cookbook', cwd: '~/learn-chef')

  # 1. Create cookbooks directory

  with_snippet_options(step: 'create-cookbooks-directory') do

    snippet_execute 'mkdir-cookbooks' do
      command 'mkdir ~/learn-chef/cookbooks'
      not_if 'stat ~/learn-chef/cookbooks'
    end

    snippet_execute 'cd-cookbooks' do
      command 'cd ~/learn-chef/cookbooks'
    end

  end

  # 1. Get cookbook from github

  with_snippet_options(step: 'git-clone-cookbook', cwd: '~/learn-chef/cookbooks') do

    snippet_execute "git-clone-#{cookbook}" do
      command "git clone https://github.com/learn-chef/#{cookbook}.git"
      not_if "stat ~/learn-chef/cookbooks/#{cookbook}"
    end

  end

  # Upload your cookbook to the Chef server

  with_snippet_options(step: 'upload-0-1-0') do

    snippet_execute "knife-cookbook-upload-#{cookbook}" do
      command "knife cookbook upload #{cookbook}"
      not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook}"
    end

    snippet_execute "knife-cookbook-list-#{cookbook}" do
      command 'knife cookbook list'
      remove_lines_matching [/((?!#{cookbook}).)*]/] # ignore all other cookbooks
    end

  end
end
