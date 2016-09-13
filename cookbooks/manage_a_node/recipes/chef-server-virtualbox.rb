#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-virtualbox
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~/learn-chef')

with_snippet_options(step: 'mkdir-chef-server') do

  snippet_execute 'mkdir-chef-server' do
    command 'mkdir ~/learn-chef/chef-server'
    not_if 'stat ~/learn-chef/chef-server'
  end

  snippet_execute 'cd-chef-server' do
    command 'cd ~/learn-chef/chef-server'
  end
end

with_snippet_options(step: 'vagrant-up-chef-server', cwd: '~/learn-chef/chef-server') do

  # Render template Vagrantfile.erb to /tmp.
  template '/tmp/Vagrantfile' do
    source 'Vagrantfile.erb'
    variables({
      :channel => node['products']['versions']['chef_server']['ubuntu'].split('-')[0],
      :version => node['products']['versions']['chef_server']['ubuntu'].split('-')[1]
    })
  end

  # Write Vagrantfile.
  snippet_code_block 'vagrantfile' do
    file_path '~/learn-chef/chef-server/Vagrantfile'
    content lazy { ::File.open('/tmp/Vagrantfile').read }
  end

  # Vagrant up.
  snippet_execute 'vagrant-up' do
    command 'vagrant up'
    trim_stdout ({
      from: /^\s+chef-server\: Progress\: 0% \(Rate\: 0\/s, Estimated time remaining: --\:--\:--\)/,
      to: /^==> node1\:   autogen-libopts.+$\n/
    })
  end
end

## 1. STEP

with_snippet_options(step: 'mkdir-dot-chef') do

  snippet_execute 'mkdir-dot-chef' do
    command 'mkdir ~/learn-chef/.chef'
    not_if 'stat ~/learn-chef/.chef'
  end
end

with_snippet_options(step: 'generate-knife-config') do

  # Get admin key.

  # TODO: Create node attribute for admin.pem.
  snippet_execute 'copy-admin-key' do
    command 'cp ~/learn-chef/chef-server/secrets/admin.pem ~/learn-chef/.chef'
  end

  # Generate knife config.

  # TODO: Create node attribute for 4thcoffee.
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
EOH
  end

  snippet_execute 'add-chef-server-to-hosts-file' do
    command 'echo "10.1.1.33 chef-server.test" | tee -a /etc/hosts'
  end

end

# 1. STEP

with_snippet_options(step: 'ls-dot-chef') do

  snippet_execute 'ls-dot-chef' do
    command 'ls ~/learn-chef/.chef'
  end

end

# 1. STEP

with_snippet_options(step: 'validate-ssl-cert') do

  snippet_execute 'knife-ssl-fetch' do
    command 'knife ssl fetch'
  end

  snippet_execute 'knife-ssl-check' do
    command 'knife ssl check'
  end

end
