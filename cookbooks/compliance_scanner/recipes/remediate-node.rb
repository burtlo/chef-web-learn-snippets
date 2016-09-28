#
# Cookbook Name:: compliance_scanner
# Recipe:: remediate-node
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

scenario_data = node['scenario']
cookbook_name = scenario_data['cookbook_name']
rule_name = scenario_data['rule_name']
node_platform = scenario_data['node_platform']
compliance_profile = scenario_data['compliance_profile']

node1 = node["nodes"][node_platform]["node1"]

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
directory ::File.expand_path('~/.ssh')
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

with_snippet_options(lesson: 'remediate-the-compliance-failure-on-your-node')

# 1. Upload the #{cookbook_name} cookbook to your Chef server

with_snippet_options(cwd: '~/learn-chef', step: 'upload-the-cookbook') do

  # knife cookbook upload #{cookbook_name}
  snippet_execute 'knife-cookbook-upload' do
    command "knife cookbook upload #{cookbook_name}"
    not_if "knife cookbook list --config ~/learn-chef/.chef/knife.rb | grep #{cookbook_name}"
  end
end

# 2. Bootstrap your node

with_snippet_options(cwd: '~/learn-chef', step: 'bootstrap-your-node') do

  # knife bootstrap 192.168.77.78 --ssh-user vagrant --sudo --identity-file ~/.ssh/node1 --node-name node1 --run-list 'recipe[#{cookbook_name}]'
  snippet_execute 'bootstrap-node1' do
    command "knife bootstrap #{node1['ip_address']} --ssh-user #{node1['ssh_user']} --sudo --identity-file ~/.ssh/node1 --node-name node1 --run-list 'recipe[#{cookbook_name}]'"
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
          "profile" => compliance_profile,
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

  # Grab chef-client version from node before cleaning up.
  execute 'get-node-chef-client-version' do
    command %q{knife exec -E 'nodes.find("name:node1") {|n| puts n.attributes.automatic.chef_packages.chef.version }' --config ~/learn-chef/.chef/knife.rb > /tmp/node1-chef-client-version}
  end
  
  # knife cookbook delete #{cookbook_name}
  snippet_execute 'knife-cookbook-delete' do
    command "knife cookbook delete #{cookbook_name} --all --yes"
  end

end
