#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: remediate-locally
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

scenario_data = node['scenario']
cookbook_name = scenario_data['cookbook_name']
rule_name = scenario_data['rule_name']
node_platform = scenario_data['node_platform']

node1 = node["nodes"][node_platform]["node1"]

default_recipe = "~/learn-chef/cookbooks/#{cookbook_name}/recipes/default.rb"
kitchen_yml = "~/learn-chef/cookbooks/#{cookbook_name}/.kitchen.yml"
sshd_config = "~/learn-chef/cookbooks/ssh/files/sshd_config"

directory '~/learn-chef/cookbooks' do
  action :delete
  recursive true
end

if scenario_data['node_platform'] == 'windows'
  # Install vagrant-winrm to work with Windows on Vagrant/VirtualBox.
  execute 'install-vagrant-winrm' do
    command 'vagrant plugin install vagrant-winrm'
    not_if 'vagrant plugin list | grep vagrant-winrm'
  end
  # Import base box
  execute 'vagrant-box-add-mwrock-windows2012r2' do
    command 'vagrant box add mwrock/Windows2012R2 --provider virtualbox'
    not_if 'vagrant box list | grep mwrock/Windows2012R2'
  end
end

with_snippet_options(lesson: 'remediate-the-compliance-failure-locally')

# 1. Understand the compliance failure

with_snippet_options(cwd: '~', step: 'understand-the-compliance-failure') do

  # ssh -i ~/.ssh/node1 vagrant@10.1.1.35 cat /etc/ssh/sshd_config | grep Protocol -B 3 -A 3
  # snippet_execute 'grep-sshd_config' do
  #   command "ssh -i #{node1['identity_file']} #{node1['ssh_user']}@#{node1['ip_address']} sudo cat /etc/ssh/sshd_config | grep Protocol"
  # end

end

# 2. Login to the Chef compliance scanner through the InSpec CLI

with_snippet_options(cwd: '~', step: 'login-to-compliance-scanner') do

  snippet_execute 'inspec-compliance-login' do
    command lazy { "inspec compliance login https://#{node['compliance']['hostname']} --user #{node['compliance']['username']} --insecure --refresh_token '#{node['compliance']['refresh_token']}'" }
  end

  snippet_execute 'inspec-compliance-profiles' do
    command 'inspec compliance profiles'
  end

end

# 3. Create the #{cookbook_name} cookbook

with_snippet_options(cwd: '~/learn-chef', step: "create-the-#{cookbook_name}-cookbook") do

  snippet_execute 'cd-learn-chef-1' do
    cwd '~'
    command 'cd ~/learn-chef'
  end

  snippet_execute 'mkdir-learn-chef-cookbooks' do
    command 'mkdir cookbooks'
    not_if 'stat ~/learn-chef/cookbooks'
  end

  snippet_execute 'chef-generate-cookbook' do
    command "chef generate cookbook cookbooks/#{cookbook_name}"
    not_if "stat ~/learn-chef/cookbooks/#{cookbook_name}"
  end

end

# 4. Apply the #{cookbook_name} cookbook on a Test Kitchen instance

with_snippet_options(cwd: "~/learn-chef/cookbooks/#{cookbook_name}", step: "apply-the-#{cookbook_name}-cookbook") do

  # .kitchen.yml
  snippet_code_block 'kitchen-1-yml' do
    file_path kitchen_yml
    source_filename "#{node_platform}/.kitchen.yml"
  end

  # .kitchen.local.yml
  cookbook_file ::File.expand_path("~/learn-chef/cookbooks/#{cookbook_name}/.kitchen.local.yml") do
    source "#{node_platform}/.kitchen.local.yml"
  end

  # cd ~/learn-chef/cookbooks/#{cookbook_name}
  snippet_execute "cd-learn-chef-cookbooks-#{cookbook_name}-1" do
    cwd '~/learn-chef'
    command "cd ~/learn-chef/cookbooks/#{cookbook_name}"
  end

  # kitchen list
  snippet_execute 'kitchen-list-1' do
    command 'kitchen list'
  end

  # kitchen converge
  snippet_execute 'kitchen-converge-1' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
  end
end

# 5. Replicate the failure on your Test Kitchen instance

with_snippet_options(cwd: "~/learn-chef/cookbooks/#{cookbook_name}", step: "apply-the-#{cookbook_name}-cookbook") do

  # review .kitchen.yml
  snippet_code_block 'kitchen-2-yml' do
    file_path kitchen_yml
    content lazy { ::File.read(::File.expand_path(kitchen_yml)) }
  end

  unless scenario_data['node_platform'] == 'windows' # takes too long on Windows :/
    # kitchen verify
    snippet_execute 'kitchen-verify' do
      command 'kitchen verify'
      ignore_failure true
    end
  end

  # kitchen verify > verify.txt 2>&1
  snippet_execute 'kitchen-verify-redirect-1' do
    command 'kitchen verify > verify.txt 2>&1'
    ignore_failure true
  end

  # cat verify.txt | grep '#{rule_name}'
  snippet_execute 'grep-rule-1' do
    command "cat verify.txt | grep '#{rule_name}'"
  end
end

# 6. Remediate the failure

with_snippet_options(cwd: "~/learn-chef/cookbooks/#{cookbook_name}", step: 'remediate-the-failure') do

  # cd ~/learn-chef
  snippet_execute 'cd-learn-chef-2' do
    cwd "~/learn-chef/cookbooks/#{cookbook_name}"
    command 'cd ~/learn-chef'
  end

  if node_platform == 'rhel'
    # chef generate file cookbooks/ssh ssh_config
    snippet_execute 'chef-generate-file' do
      cwd '~/learn-chef'
      command "chef generate file cookbooks/ssh ssh_config"
    end

    # sshd_config
    snippet_code_block 'sshd_config' do
      file_path sshd_config
      source_filename 'rhel/sshd_config'
    end
  end

  # default.rb
  snippet_code_block 'default-rb' do
    file_path default_recipe
    source_filename "#{node_platform}/default.rb"
  end

  # cd ~/learn-chef/cookbooks/#{cookbook_name}
  snippet_execute "cd-learn-chef-cookbooks-#{cookbook_name}-2" do
    cwd '~/learn-chef'
    command "cd ~/learn-chef/cookbooks/#{cookbook_name}"
  end

  # kitchen converge
  snippet_execute 'kitchen-converge-2' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/, /Reading database/]
  end

  # kitchen verify > verify.txt 2>&1
  snippet_execute 'kitchen-verify-redirect-2' do
    command 'kitchen verify > verify.txt 2>&1'
    ignore_failure true
  end

  # cat verify.txt | grep '#{rule_name}'
  snippet_execute 'grep-rule-2' do
    command "cat verify.txt | grep '#{rule_name}'"
  end

  # kitchen login ...
  # TODO: Can't do it non-interactively; kitchen exec --commmand cat /etc/ssh/sshd_config doesn't produce any output.

  if scenario_data['kitchen_exec']
    snippet_execute 'kitchen-exec-1' do
      command scenario_data['kitchen_exec']
    end
  end

  # kitchen destroy
  snippet_execute 'kitchen-destroy' do
    command 'kitchen destroy'
  end
end
