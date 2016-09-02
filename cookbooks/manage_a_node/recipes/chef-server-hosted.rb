#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-hosted
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~/learn-chef')

## 1. STEP

with_snippet_options(step: 'DUNNO1') do

  snippet_execute 'mkdir-dot-chef' do
    command 'mkdir ~/learn-chef/.chef'
    not_if 'stat ~/learn-chef/.chef'
  end

end

# Simulate obtaining knife config and user key.

%w[knife.rb chef-user-1.pem].each do |f|
  file ::File.expand_path("~/learn-chef/.chef/#{f}") do
    content ::File.open("/vagrant/.chef/#{f}").read
  end
end

# 1. STEP

with_snippet_options(step: 'DUNNO2') do

  snippet_execute 'ls-dot-chef' do
    command 'ls ~/learn-chef/.chef'
  end

end

# 1. STEP

with_snippet_options(step: 'DUNNO3') do

  snippet_execute 'knife-ssl-check' do
    command 'knife ssl check'
  end

end
