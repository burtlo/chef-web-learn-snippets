#
# Cookbook Name:: create_a_web_app
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(
  tutorial: 'create-a-web-app-cookbook',
  platform: 'shared',
  virtualization: 'vagrant',
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe 'manage_a_node::workstation'

  shell = node['platform'] == 'windows' ? 'ps' : nil
  with_snippet_options(
    lesson: 'set-up-your-workstation',
    shell: shell,
    cwd: '~',
    step: 'set-up-your-working-directory') do

    ### Prerequisite setup

    # Install vagrant-winrm to work with Windows on Vagrant/VirtualBox.
    snippet_execute 'install-vagrant-winrm' do
      command 'vagrant plugin install vagrant-winrm'
      not_if 'vagrant plugin list | grep vagrant-winrm'
    end

    directory ::File.expand_path('~/learn-chef')

    ###
  end

  #include_recipe 'create_a_web_app::lamp'
  #include_recipe 'create_a_web_app::lamp_customers'
  include_recipe 'create_a_web_app::wisa'
  include_recipe 'create_a_web_app::wisa_customers'
end
