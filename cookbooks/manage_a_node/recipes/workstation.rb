#
# Cookbook Name:: manage_a_node
# Recipe:: workstation
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install git
git_client 'default' do
  action :install
end

# Install Chef DK
shell = node['platform'] == 'windows' ? 'ps' : nil
with_snippet_options(lesson: 'set-up-your-workstation', shell: shell) do

  # Install Chef DK

  include_recipe 'workstation::chefdk'

  # Set up your working directory

  with_snippet_options(cwd: '~', step: 'set-up-your-working-directory') do

    unless node['snippets']['virtualization'] == 'opsworks'
      snippet_execute 'mkdir-learn-chef' do
        command 'mkdir ~/learn-chef'
        not_if 'stat ~/learn-chef'
      end

      snippet_execute 'cd-learn-chef' do
        command 'cd ~/learn-chef'
      end
    end

  end

  # Install git
  with_snippet_options(cwd: '~', step: 'install-git') do
    snippet_execute 'git-version' do
      command 'git --version'
    end
  end

end
