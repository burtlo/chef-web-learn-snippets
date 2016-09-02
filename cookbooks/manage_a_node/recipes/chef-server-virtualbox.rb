#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-virtualbox
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

with_snippet_options(step: 'DUNNO4') do

  # Get validation key.

  # TODO: Create node attribute for 4thcoffee-validator.pem.
  # TODO: Source will later be ~/learn-chef/chef-server or similar.
  # TOOD: LIKELY CAN GO AWAY
  # snippet_execute 'copy-vaidation-key' do
  #   command 'cp /vagrant/secrets/4thcoffee-validator.pem ~/learn-chef/.chef'
  # end

  # TODO: Create node attribute for admin.pem.
  # TODO: Source will later be ~/learn-chef/chef-server or similar.
  snippet_execute 'copy-vaidation-key' do
    command 'cp /vagrant/secrets/admin.pem ~/learn-chef/.chef'
  end

  # Generate knife config

  # TODO: Create node attribute for 4thcoffee.
  # TODO: Remove validation key refs if not needed.
  snippet_code_block 'knife-rb' do
    file_path '~/learn-chef/.chef/knife.rb'
    content <<-'EOH'
# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
chef_server_url          "https://chef-server.test/organizations/4thcoffee"
cookbook_path            ["#{current_dir}/../cookbooks"]
#validation_client_name   "4thcoffee-validator"
#validation_key           "#{current_dir}/4thcoffee-validator.pem"
#ssl_verify_mode          :verify_peer
EOH
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

  snippet_execute 'knife-ssl-fetch' do
    command 'knife ssl fetch'
  end

  snippet_execute 'knife-ssl-check' do
    command 'knife ssl check'
  end

end
