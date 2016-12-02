#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-opsworks
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
package 'unzip'
package 'tree'

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~')

  with_snippet_options(step: 'extract-starter-kit') do

    # Extract starter kit.
    snippet_execute 'unzip-starter-kit' do
      #command %q{dest=~/learn-chef bash -c 'unzip -d "$dest" ~/Downloads/starter_kit.zip && f=("$dest"/*) && mv "$dest"/*/{.chef,*} "$dest" && rmdir "${f[@]}"'}
      command 'unzip ~/Downloads/starter_kit.zip'
      not_if 'stat ~/learn-chef'
    end

    # Rename root directory.
    root_dir = "~/#{node['chef_automate']['fqdn'].split('.')[0]}"
    snippet_execute 'rename-root-dir' do
      command "mv #{root_dir} ~/learn-chef"
      not_if 'stat ~/learn-chef'
    end

    ### TODO: This is a temporary workaround for a bug.
    ruby_block 'patch-knife-rb' do
      block do
        file_name = ::File.expand_path('~/learn-chef/.chef/knife.rb')
        text = ::File.read(file_name)
        new_contents = text.sub("cookbook_path[", "cookbook_path [")
        # To write changes to the file, use:
        ::File.open(file_name, "w") {|file| file.write new_contents }
      end
    end

    # tree result.
    snippet_execute 'tree-starter-kit' do
      command 'tree -a ~/learn-chef'
    end
end

with_snippet_options(lesson: 'get-a-node-to-bootstrap', step: 'copy-server-certificate', cwd: '~') do

  # Copy cert from Chef Automate to nodes
  # node['nodes'].each do |n|
  #   node_name = n['name']
  #   ip_address = n['ip_address']
  #   username = n['ssh_user'] || n['winrm_user']
  #
  #   case n['platform']
  #   when 'rhel', 'ubuntu'
  #     snippet_execute "upload-automate-certificate-to-#{node_name}" do
  #       command "scp -i #{n['identity_file']} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ~/learn-chef/.chef/ca_certs #{username}@#{ip_address}:/etc/chef/trusted_certs/"
  #     end
  #   when 'windows'
  #     template '/tmp/upload-cert.rb' do
  #       source 'upload-cert.rb.erb'
  #       variables({
  #         :ip_address => ip_address,
  #         :username => username,
  #         :password => n['password'],
  #         :cert_file => "cert_name" # TODO
  #       })
  #     end
  #     snippet_code_block "upload-cert-rb" do
  #       file_path "/tmp/upload-cert.rb"
  #       content lazy {
  #         ::File.read(::File.expand_path("/tmp/upload-cert.rb"))
  #       }
  #     end
  #     snippet_execute "upload-automate-certificate-to-#{node_name}" do
  #       command "chef exec ruby /tmp/upload-cert.rb"
  #     end
  #   end
  # end
end

with_snippet_options(step: 'generate-knife-config') do

  snippet_code_block 'knife-rb' do
    file_path '~/learn-chef/.chef/knife.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/.chef/knife.rb')) }
    write_system_file false
  end

end

with_snippet_options(step: 'ls-dot-chef') do

  snippet_execute 'ls-dot-chef' do
    command 'ls ~/learn-chef/.chef'
  end

end

with_snippet_options(step: 'validate-ssl-cert') do

  snippet_execute 'cd-learn-chef' do
    command 'cd ~/learn-chef'
  end

  # snippet_execute 'knife-ssl-fetch' do
  #   command 'knife ssl fetch'
  #   cwd '~/learn-chef'
  # end

  snippet_execute 'knife-ssl-check' do
    command 'knife ssl check'
    cwd '~/learn-chef'
  end

end
