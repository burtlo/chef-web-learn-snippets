#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-hosted
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~/learn-chef')

with_snippet_options(step: 'mkdir-dot-chef') do

  snippet_execute 'mkdir-dot-chef' do
    command 'mkdir ~/learn-chef/.chef'
    not_if 'stat ~/learn-chef/.chef'
  end

end

# Simulate obtaining knife config and user key.
# TODO: Use this template in other scenarios...

template '/tmp/knife.rb' do
  source 'knife.rb.erb'
  variables({
    :node_name => "delivery",
    :client_key => "delivery.pem",
    :chef_server_url => "https://#{node['chef_server']['fqdn']}/organizations/#{node['chef_server']['org']}"
  })
end

with_snippet_options(step: 'generate-knife-config') do

  snippet_code_block 'knife-rb' do
    file_path '~/learn-chef/.chef/knife.rb'
    content lazy { ::File.read('/tmp/knife.rb') }
  end

  file ::File.expand_path("~/learn-chef/.chef/delivery.pem") do
    content ::File.read("/tmp/delivery.pem")
  end

end

with_snippet_options(step: 'ls-dot-chef') do

  snippet_execute 'ls-dot-chef' do
    command 'ls ~/learn-chef/.chef'
  end

end

with_snippet_options(step: 'validate-ssl-cert') do

  snippet_execute 'knife-ssl-fetch' do
    command 'knife ssl fetch'
  end

  snippet_execute 'knife-ssl-check' do
    command 'knife ssl check'
  end

end
