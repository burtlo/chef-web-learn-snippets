#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: remediate-locally
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

default_recipe = '~/learn-chef/cookbooks/ssh/recipes/default.rb'
kitchen_yml = '~/learn-chef/cookbooks/ssh/.kitchen.yml'
sshd_config = '~/learn-chef/cookbooks/ssh/files/sshd_config'

directory '~/learn-chef/cookbooks' do
  action :delete
  recursive true
end

node1 = node["nodes"]["rhel"]["node1"]

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

# 3. Create the ssh cookbook

with_snippet_options(cwd: '~/learn-chef', step: 'create-the-ssh-cookbook') do

  snippet_execute 'cd-learn-chef-1' do
    cwd '~'
    command 'cd ~/learn-chef'
  end

  snippet_execute 'mkdir-learn-chef-cookbooks' do
    command 'mkdir cookbooks'
    not_if 'stat ~/learn-chef/cookbooks'
  end

  snippet_execute 'chef-generate-cookbook' do
    command 'chef generate cookbook cookbooks/ssh'
    not_if 'stat ~/learn-chef/cookbooks/ssh'
  end

end

# 4. Apply the ssh cookbook on a Test Kitchen instance

with_snippet_options(cwd: '~/learn-chef/cookbooks/ssh', step: 'apply-the-ssh-cookbook') do

  # .kitchen.yml
  snippet_code_block 'kitchen-1-yml' do
    file_path kitchen_yml
    source_filename 'rhel/.kitchen.yml'
  end

  # cd ~/learn-chef/cookbooks/ssh
  snippet_execute 'cd-learn-chef-cookbooks-ssh-1' do
    cwd '~/learn-chef'
    command 'cd ~/learn-chef/cookbooks/ssh'
  end

  # kitchen list
  snippet_execute 'kitchen-list-1' do
    command 'kitchen list'
  end

  # kitchen converge
  snippet_execute 'kitchen-converge-1' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end
end

# 5. Replicate the failure on your Test Kitchen instance

with_snippet_options(cwd: '~/learn-chef/cookbooks/ssh', step: 'apply-the-ssh-cookbook') do

  # review .kitchen.yml
  snippet_code_block 'kitchen-2-yml' do
    file_path kitchen_yml
    content lazy { ::File.read(::File.expand_path(kitchen_yml)) }
  end

  # kitchen verify
  snippet_execute 'kitchen-verify' do
    command 'kitchen verify'
    ignore_failure true
  end

  # kitchen verify > verify.txt 2>&1
  snippet_execute 'kitchen-verify-redirect-1' do
    command 'kitchen verify > verify.txt 2>&1'
    ignore_failure true
  end

  # cat verify.txt | grep 'Set SSH Protocol to 2'
  snippet_execute 'grep-ssh-protocol-1' do
    command %q[cat verify.txt | grep 'Set SSH Protocol to 2']
  end
end

# 6. Remediate the failure

with_snippet_options(cwd: '~/learn-chef/cookbooks/ssh', step: 'remediate-the-failure') do

  # cd ~/learn-chef
  snippet_execute 'cd-learn-chef-2' do
    cwd '~/learn-chef/cookbooks/ssh'
    command 'cd ~/learn-chef'
  end

  # chef generate file cookbooks/ssh ssh_config
  snippet_execute 'chef-generate-file' do
    cwd '~/learn-chef'
    command 'chef generate file cookbooks/ssh ssh_config'
  end

  # sshd_config
  snippet_code_block 'sshd_config' do
    file_path sshd_config
    source_filename 'rhel/sshd_config'
  end

  # default.rb
  snippet_code_block 'default-rb' do
    file_path default_recipe
    source_filename 'rhel/default.rb'
  end

  # cd ~/learn-chef/cookbooks/ssh
  snippet_execute 'cd-learn-chef-cookbooks-ssh-2' do
    cwd '~/learn-chef'
    command 'cd ~/learn-chef/cookbooks/ssh'
  end

  # kitchen converge
  snippet_execute 'kitchen-converge-2' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

  # kitchen verify > verify.txt 2>&1
  snippet_execute 'kitchen-verify-redirect-2' do
    command 'kitchen verify > verify.txt 2>&1'
    ignore_failure true
  end

  # cat verify.txt | grep 'Set SSH Protocol to 2'
  snippet_execute 'grep-ssh-protocol-2' do
    command %q[cat verify.txt | grep 'Set SSH Protocol to 2']
  end

  # kitchen login ...
  # TODO: Can't do it non-interactively; kitchen exec --commmand cat /etc/ssh/sshd_config doesn't produce any output.

  # kitchen destroy
  snippet_execute 'kitchen-destroy' do
    command 'kitchen destroy'
  end
end
