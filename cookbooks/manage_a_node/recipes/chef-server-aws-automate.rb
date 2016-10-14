#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-aws-automate
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~/learn-chef')

with_snippet_options(step: 'mkdir-dot-chef') do

  snippet_execute 'mkdir-dot-chef' do
    command 'mkdir ~/learn-chef/.chef'
    not_if 'stat ~/learn-chef/.chef'
  end

end

chef_automate_fqdn = node['chef_automate']['fqdn']
chef_server_fqdn = node['chef_server']['fqdn']
cert_name = "#{chef_automate_fqdn}.crt"

with_snippet_options(lesson: 'set-up-your-chef-server', cwd: '~') do

  ##
  ## Install Chef server
  ##
  # Generate install template.
  template '/tmp/install-chef-server.sh' do
    source 'install-chef-server.sh.erb'
    variables({
      :chef_server_channel => node['products']['versions']['chef_server']['ubuntu'].split('-')[0],
      :chef_server_version => node['products']['versions']['chef_server']['ubuntu'].split('-')[1]
    })
    mode '0700'
    not_if 'stat /tmp/chef-server.installed' # only do this once
  end
  with_snippet_options(step: 'create-chef-server-install-script') do
    snippet_code_block 'install-chef-server-sh' do
      file_path '/tmp/install-chef-server.sh'
      content lazy { ::File.read('/tmp/install-chef-server.sh') }
      not_if 'stat /tmp/chef-server.installed' # only do this once
    end
  end

  # scp it up
  execute 'scp-install-chef-server.sh' do
    command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/install-chef-server.sh ubuntu@#{chef_server_fqdn}:/tmp"
    not_if 'stat /tmp/chef-server.installed' # only do this once
  end
  # run the install remotely
  execute 'ssh-install-chef-server.sh' do
    command "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn} \"sudo bash -s\" < /tmp/install-chef-server.sh"
    not_if 'stat /tmp/chef-server.installed' # only do this once
  end
  # grab the admin.pem
  with_snippet_options(step: 'download-admin-pem') do
    snippet_execute 'download-admin-pem-to-workstation' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn}:/tmp/admin.pem ~/learn-chef/.chef"
      not_if 'stat /tmp/chef-server.installed' # only do this once
    end
  end
  # grab the delivery.pem
  with_snippet_options(step: 'download-delivery-pem') do
    snippet_execute 'download-delivery-pem-to-workstation' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn}:/tmp/delivery.pem /tmp"
      not_if 'stat /tmp/chef-server.installed' # only do this once
    end
  end

  file '/tmp/chef-server.installed' # mark Chef server as installed

  # Copy license to Chef Automate server
  with_snippet_options(step: 'copy-license-to-chef-automate') do
    snippet_execute 'scp-license' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ~/Downloads/automate.license ubuntu@#{chef_automate_fqdn}:/tmp"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
  end
  # Copy delivery.pem to Chef Automate server
  with_snippet_options(step: 'copy-delivery-pem-to-chef-automate') do
    snippet_execute 'upload-delivery-pem-to-automate' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/delivery.pem ubuntu@#{chef_automate_fqdn}:/tmp"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
  end

  ##
  ## Install Chef Automate
  ##
  # Generate install template.
  template '/tmp/install-chef-automate.sh' do
    source 'install-chef-automate.sh.erb'
    variables({
      :delivery_channel => node['products']['versions']['automate']['ubuntu'].split('-')[0],
      :delivery_version => node['products']['versions']['automate']['ubuntu'].split('-')[1]
    })
    mode '0700'
    not_if 'stat /tmp/chef-automate.installed' # only do this once
  end
  with_snippet_options(step: 'create-chef-automate-install-script') do
    snippet_code_block 'install-chef-automate-sh' do
      file_path '/tmp/install-chef-automate.sh'
      content lazy { ::File.read('/tmp/install-chef-automate.sh') }
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
  end
  # scp it up
  execute 'scp-install-chef-automate.sh' do
    command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/install-chef-automate.sh ubuntu@#{chef_automate_fqdn}:/tmp"
    not_if 'stat /tmp/chef-automate.installed' # only do this once
  end
  # run the install remotely
  execute 'ssh-install-chef-automate.sh' do
    command "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_automate_fqdn} \"sudo bash -s\" < /tmp/install-chef-automate.sh \"#{chef_server_fqdn}\""
    not_if 'stat /tmp/chef-automate.installed' # only do this once
  end

  # We'll later need to copy Automate's server certificate to our nodes.
  # Grab the cert now.
  with_snippet_options(step: 'copy-server-certificate') do
    snippet_execute 'download-automate-certificate-to-workstation' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_automate_fqdn}:/var/opt/delivery/nginx/ca/#{cert_name} /tmp/#{cert_name}"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
  end

  # Set up data collector on Chef server
  # First, render it locally
  template '/tmp/data_collector.rb' do
    source 'data_collector.rb.erb'
    variables({
      :data_collector_url => "https://#{chef_automate_fqdn}"
    })
  end
  with_snippet_options(step: 'set-up-data-collection') do
    snippet_code_block 'data_collector-rb' do
      file_path '/etc/opscode/chef-server.rb'
      content lazy { ::File.read('/tmp/data_collector.rb') }
      write_system_file false
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
    snippet_execute 'upload-data-collector-rb' do
      command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/data_collector.rb ubuntu@#{chef_server_fqdn}:/tmp/chef-server.rb"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
    snippet_execute 'copy-data-collector-rb' do
      command "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn} 'sudo cp /tmp/chef-server.rb /etc/opscode/chef-server.rb'"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
    snippet_execute 'chef-server-ctl-reconfigure-and-restart' do
      command "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn} 'sudo chef-server-ctl reconfigure && sudo chef-server-ctl restart'"
      not_if 'stat /tmp/chef-automate.installed' # only do this once
    end
  end

  file '/tmp/chef-automate.installed' # mark Chef Automate as installed

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
        command "scp -i #{n['identity_file']} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/#{cert_name} #{username}@#{ip_address}:/etc/chef/trusted_certs"
      end
    when 'windows'
      template '/tmp/upload-cert.rb' do
        source 'upload-cert.rb.erb'
        variables({
          :ip_address => ip_address,
          :username => username,
          :password => n['password'],
          :cert_file => cert_name
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

##################



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
    content lazy { ::File.read('/tmp/knife.rb') }
  end

  # grab the admin.pem from Chef server
  snippet_execute 'download-admin-pem-to-workstation' do
    command "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@#{chef_server_fqdn}:/tmp/admin.pem ~/learn-chef/.chef"
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
