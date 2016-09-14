#
# Cookbook Name:: manage_a_node
# Recipe:: bootstrap-node
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Ensure Chef server doesn't have node1.
execute 'ensure-knife-node-delete-node1' do
  command 'knife node delete node1 --yes --config ~/learn-chef/.chef/knife.rb'
  only_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
end
execute 'ensure-knife-client-delete-node1' do
  command 'knife client delete node1 --yes --config ~/learn-chef/.chef/knife.rb'
  only_if 'knife client list --config ~/learn-chef/.chef/knife.rb | grep node1'
end

directory ::File.expand_path('~/.ssh')

with_snippet_options(lesson: 'bootstrap-your-node', cwd: '~/learn-chef')

with_snippet_options(step: 'bootstrap-your-node') do

  # node1 = {
  #   'ip_address' => '54.86.203.50', #lazy { ['node1'] },
  #   'ssh_user' => 'centos',
  #   'identity_file' => '~/.ssh/private_key',
  #   'run_list' => 'recipe[learn_chef_httpd]'
  # }
  #
  # snippet_execute 'bootstrap-node1-key-based-auth' do
  #   command "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file #{node1['identity_file']} --node-name node1 --run-list '#{node1['run_list']}'"
  #   not_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
  # end

  node1 = node['nodes']['rhel']['node1']

  case node['snippets']['virtualization']
  when 'aws-automate', 'aws-marketplace', 'azure-marketplace'
    node.run_state['bootstrap_command'] = "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file #{node1['identity_file']} --node-name node1 --run-list '#{node1['run_list']}'"
  when 'hosted'
    # Place private key
    file "node1-private-key"  do
      path ::File.expand_path(node1['identity_file'])
      content ::File.open("/vagrant/.vagrant/machines/#{node1['name']}/vmware_fusion/private_key").read
      mode '0600'
    end
    node.run_state['bootstrap_command'] = "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file #{node1['identity_file']} --node-name node1 --run-list '#{node1['run_list']}'"
  when 'virtualbox'
    # TODO: add this as a snippet command
    ruby_block 'vagrant-ssh-config-node1-1' do
      block do
        lines = `cd ~/learn-chef/chef-server && vagrant ssh-config node1`.split("\n")
        user = lines.grep(/\s*User\s+(.*)$/){$1}[0]
        port = lines.grep(/\s*Port\s+(.*)$/){$1}[0]
        identity_file = lines.grep(/\s*IdentityFile\s+(.*)$/){$1}[0]

        node.run_state['bootstrap_command'] = "knife bootstrap localhost --ssh-port #{port} --ssh-user #{user} --sudo --identity-file #{identity_file} --node-name node1 --run-list '#{node1['run_list']}'"
        # Host default
        # HostName 127.0.0.1
        # User vagrant
        # Port 2222
        # UserKnownHostsFile /dev/null
        # StrictHostKeyChecking no
        # PasswordAuthentication no
        # IdentityFile /Users/babo/src/centos/.vagrant/machines/default/virtualbox/private_key
        # IdentitiesOnly yes
        # LogLevel FATAL
      end
    end
  end

  snippet_execute 'bootstrap-node1-key-based-auth' do
    command lazy { node.run_state['bootstrap_command'] }
    remove_lines_matching [/locale/, /#########/]
    not_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
  end

  snippet_execute 'knife-node-list' do
    command "knife node list"
  end

  snippet_execute 'knife-node-show' do
    command "knife node show node1"
  end

  snippet_execute 'curl-node1-1' do
    command "curl #{node1['ip_address']}"
  end

  # snippet_execute 'bootstrap-node1-key-based-auth' do
  #   command "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file #{node1['identity_file']} --node-name node1 --run-list '#{node1['run_list']}'"
  #   remove_lines_matching [/locale/, /#########/]
  #   not_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
  # end



  # snippet_execute 'knife-node-delete-node1-key-based-auth' do
  #   command 'knife node delete node1 --yes'
  #   only_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
  # end
  # snippet_execute 'knife-client-delete-node1-key-based-auth' do
  #   command 'knife client delete node1 --yes'
  #   only_if 'knife client list --config ~/learn-chef/.chef/knife.rb | grep node1'
  # end

  # knife bootstrap ADDRESS --ssh-user USER --sudo --identity-file IDENTITY_FILE --node-name node1 --run-list 'recipe[learn_chef_httpd]'

  # Bootstrap using a username and password
  # knife bootstrap ADDRESS --ssh-user USER --ssh-password 'PASSWORD' --sudo --use-sudo-password --node-name node1 --run-list 'recipe[learn_chef_httpd]'

  # Bootstrap a local virtual machine using a forwarded port
  # knife bootstrap localhost --ssh-port PORT --ssh-user vagrant --sudo --identity-file IDENTITY_FILE --node-name node1 --run-list 'recipe[learn_chef_httpd]'
end
