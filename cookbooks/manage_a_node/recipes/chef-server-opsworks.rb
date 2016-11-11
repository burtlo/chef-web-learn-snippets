#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-opsworks
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
package 'unzip'
package 'tree'

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~/learn-chef')

  with_snippet_options(step: 'extract-starter-kit') do

    # Extract starter kit.
    snippet_execute 'unzip-starter-kit' do
      command %q{dest=~/learn-chef bash -c 'unzip -d "$dest" ~/Downloads/download.zip && f=("$dest"/*) && mv "$dest"/*/{.chef,*} "$dest" && rmdir "${f[@]}"'}
      not_if 'stat ~/learn-chef/.chef/knife.rb'
    end

    # tree result.
    snippet_execute 'tree-starter-kit' do
      command 'tree -a ~/learn-chef'
    end
end

with_snippet_options(lesson: 'get-a-node-to-bootstrap', step: 'copy-server-certificate', cwd: '~') do

  # Copy cert from Chef Automate to nodes
  node['nodes'].each do |n|
    node_name = n['name']
    ip_address = n['ip_address']
    username = n['ssh_user'] || n['winrm_user']

    case n['platform']
    when 'rhel', 'ubuntu'
      snippet_execute "upload-automate-certificate-to-#{node_name}" do
        command "scp -i #{n['identity_file']} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ~/learn-chef/.chef/ca_certs #{username}@#{ip_address}:/etc/chef/trusted_certs/"
      end
    when 'windows'
      template '/tmp/upload-cert.rb' do
        source 'upload-cert.rb.erb'
        variables({
          :ip_address => ip_address,
          :username => username,
          :password => n['password'],
          :cert_file => "cert_name" # TODO
        })
      end
      snippet_code_block "upload-cert-rb" do
        file_path "/tmp/upload-cert.rb"
        content lazy {
          ::File.read(::File.expand_path("/tmp/upload-cert.rb"))
        }
      end
      snippet_execute "upload-automate-certificate-to-#{node_name}" do
        command "chef exec ruby /tmp/upload-cert.rb"
      end
    end
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
