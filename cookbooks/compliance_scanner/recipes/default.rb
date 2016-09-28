#
# Cookbook Name:: compliance_scanner
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

load_compliance_data

scenario_data = node['scenario']
node_platform = scenario_data['node_platform']

with_snippet_options(
  tutorial: 'compliance_scanner',
  platform: node_platform,
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character'],
  compliance_url: node['compliance']['hostname'],
  compliance_user: node['compliance']['username']
  ) do

# Generate refresh token.
snippet_compliance_api 'generate refresh token' do
  action :login
  data ({ "userid" => node['compliance']['username'], "password" => node['compliance']['password'] })
  key 'access_token'
  overwrite true
end

# Add environment.
snippet_compliance_api 'add default environment' do
  action :add_env
  data ({ "name" => "default" })
  key 'environments/default'
end

# Add SSH key.
snippet_compliance_api 'add SSH key' do
  action :add_key
  data lazy {({
    "name" => "node1",
    "private" => ::File.read('/tmp/node1')
  })}
  key 'keys/node1'
end

# Add node.
node1 = node["nodes"][node_platform]["node1"]

snippet_compliance_api 'add node' do
  action :add_node
  data lazy { [
    {
      "hostname" => node1["ip_address"],
      "name" => node1["name"],
      "environment" => get_compliance_data('environments/default')['id'],
      "loginUser" => node1["ssh_user"],
      "loginMethod" => "ssh",
      "loginKey" => "#{node['compliance']['username']}/node1"
    }
  ] }
  key 'nodes/node1'
end

snippet_compliance_api 'check connectivity' do
  action :check_connectivity
  data lazy {
    {
      "user" => node['compliance']['username'],
      "env" => get_compliance_data('environments/default')['id'],
      "node_id" => get_compliance_data('nodes/node1')[0]
    }
  }
  key 'connectivity/node1'
end

snippet_compliance_api 'scan node 1' do
  action :scan_node
  data lazy {
    {
      "compliance" => [
        "owner" => "cis",
        "profile" => scenario_data['compliance_profile'],
      ],
      "environments" => [
        "id" => get_compliance_data('environments/default')['id'],
        "nodes" => [
          get_compliance_data('nodes/node1')[0]
        ]
      ]
    }
  }
  key 'scans/node1/cis/1'
  overwrite true
end

# Install Chef DK
shell = node['platform'] == 'windows' ? 'ps' : nil
with_snippet_options(lesson: 'set-up-your-workstation', shell: shell) do
  # Install Chef DK
  include_recipe 'workstation::chefdk'
end

directory ::File.expand_path('~/learn-chef')

include_recipe 'compliance_scanner::remediate-locally'
include_recipe 'compliance_scanner::remediate-node'

# Write config file.
snippet_config 'compliance_scanner' do
  variables lazy {
    ({
      chef_client_version: ::File.read('tmp/node1-chef-client-version').strip
    })
  }
end

end
