#
# Cookbook Name:: manage_a_node
# Recipe:: update-node-config
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
with_snippet_options(lesson: 'update-your-nodes-configuration')

with_snippet_options(cwd: '~/learn-chef', step: 'add-template-code-to-your-html') do

  # Update template.
  snippet_code_block 'index-html-erb' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/templates/index.html.erb'
    source_filename 'index.html.erb'
  end

  # Update metadata.
  snippet_code_block 'metadata-0-2-0' do
    file_path '~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb'
    content lazy { ::File.open(::File.expand_path('~/learn-chef/cookbooks/learn_chef_httpd/metadata.rb')).read.sub("version '0.1.0'", "version '0.2.0'") }
  end

  # Upload your cookbook to the Chef server
  snippet_execute 'upload-0-2-0' do
    command 'knife cookbook upload learn_chef_httpd'
    not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep 'learn_chef_httpd   0.2.0'"
  end

  node1 = node['nodes']['rhel']['node1']

  if node['snippets']['virtualization'] == 'hosted'
    node.run_state['knife_ssh_command'] = "knife ssh #{node1['ip_address']} 'sudo chef-client' --manual-list --ssh-user #{node1['ssh_user']} --identity-file #{node1['identity_file']}"
  elsif node['snippets']['virtualization'] == 'virtualbox'
    ruby_block 'vagrant-ssh-config-node1' do
      block do
        lines = `cd ~/learn-chef/chef-server && vagrant ssh-config node1`.split("\n")
        user = lines.grep(/\s*User\s+(.*)$/){$1}[0]
        port = lines.grep(/\s*Port\s+(.*)$/){$1}[0]
        identity_file = lines.grep(/\s*IdentityFile\s+(.*)$/){$1}[0]

        node.run_state['knife_ssh_command'] = "knife ssh localhost --ssh-port #{port} 'sudo chef-client' --manual-list --ssh-user #{user} --identity-file #{identity_file}"
      end
    end
  end

  # knife ssh using key-based authentication
  snippet_execute 'knife-ccr-1' do
    command lazy { node.run_state['knife_ssh_command'] }
    remove_lines_matching [/locale/, /#########/]
  end

  # Confirm the result
  snippet_execute 'curl-node1-2' do
    command "curl #{node1['ip_address']}"
  end
end
