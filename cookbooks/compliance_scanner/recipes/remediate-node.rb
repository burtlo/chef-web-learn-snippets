#
# Cookbook Name:: compliance_scanner
# Recipe:: remediate-node
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Ensure we can connect to Chef server

directory ::File.expand_path('~/learn-chef/.chef')
file ::File.expand_path('~/learn-chef/.chef/knife.rb') do
  content lazy { ::File.read('/tmp/knife.rb') }
end
file ::File.expand_path('~/learn-chef/.chef/admin.pem') do
  content lazy { ::File.read('/tmp/admin.pem') }
end
execute 'knife-ssl-fetch' do
  cwd ::File.expand_path('~/learn-chef')
  command 'knife ssl fetch --config ~/learn-chef/.chef/knife.rb'
end

# Ensure we can connect to the node
file ::File.expand_path('~/.ssh/node1') do
  content lazy { ::File.read('/tmp/node1') }
end

# Clear out any previous runs.
%w[client node].each do |s|
  execute "knife-#{s}-delete" do
    command "knife #{s} delete node1 --yes --config ~/learn-chef/.chef/knife.rb"
    only_if "knife #{s} list --config ~/learn-chef/.chef/knife.rb | grep node1"
  end
end

node1 = node["nodes"]["rhel"]["node1"]

with_snippet_options(lesson: 'remediate-the-compliance-failure-on-your-node')

# 1. Upload the ssh cookbook to your Chef server

with_snippet_options(cwd: '~/learn-chef', step: 'upload-the-cookbook') do

  # knife cookbook upload ssh
  snippet_execute 'knife-cookbook-upload' do
    command 'knife cookbook upload ssh'
    not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep ssh"
  end
end

# 2. Bootstrap your node

with_snippet_options(cwd: '~/learn-chef', step: 'bootstrap-your-node') do

  # knife bootstrap 192.168.77.78 --ssh-user vagrant --sudo --identity-file ~/.ssh/node1 --node-name node1 --run-list 'recipe[ssh]'
  snippet_execute 'bootstrap-node1' do
    command "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file ~/.ssh/node1 --node-name node1 --run-list 'recipe[ssh]'"
    remove_lines_matching [/locale/, /#########/]
    not_if 'knife node list --config ~/learn-chef/.chef/knife.rb | grep node1'
  end
end

# 3. Rerun the compliance scan

with_snippet_options(cwd: '~/learn-chef', step: 'rerun-the-scan') do

  snippet_compliance_api 'scan node 2' do
    action :scan_node
    data lazy {
      {
        "compliance" => [
          "owner" => "cis",
          "profile" => "cis-centos7-level2",
        ],
        "environments" => [
          "id" => get_compliance_data('environments/default')['id'],
          "nodes" => [
            get_compliance_data('nodes/node1')[0]
          ]
        ]
      }
    }
    key 'scans/node1/cis/2'
    overwrite true
  end

end

# How to clean up your environment

with_snippet_options(cwd: '~/learn-chef', step: 'cleanup') do

  # knife cookbook delete ssh
  snippet_execute 'knife-cookbook-delete' do
    command 'knife cookbook delete ssh --all --yes'
  end

end
