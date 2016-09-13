#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-aws-marketplace
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# TODO: This is redundant with chef-server-aws. Call the other, but add node attribute for knife.rb below (node_name & client_key)

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
    :node_name => "admin",
    :client_key => "admin.pem",
    :chef_server_url => "https://#{node['chef_server']['fqdn']}/organizations/#{node['chef_server']['org']}"
  })
end

with_snippet_options(step: 'generate-knife-config') do

  snippet_code_block 'knife-rb' do
    file_path '~/learn-chef/.chef/knife.rb'
    content lazy { ::File.open('/tmp/knife.rb').read }
  end

  # TODO: When you consolidate, address this too.
  file ::File.expand_path("~/learn-chef/.chef/admin.pem") do
   content ::File.open("/tmp/admin.pem").read
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
