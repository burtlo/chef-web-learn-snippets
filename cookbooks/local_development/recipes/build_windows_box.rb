#
# Cookbook Name:: build_windows_box
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(
  tutorial: 'local-development',
  platform: 'windows',
  virtualization: 'vagrant',
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe 'manage_a_node::workstation'

  execute 'vagrant plugin install vagrant-winrm' do
    not_if 'vagrant plugin list | grep vagrant-winrm'
  end

  path = ::File.expand_path('~/learn-chef')
  git_path = ::File.join(path, 'packer-templates')

  execute "mkdir -p #{path}" do
    not_if "stat #{path}"
  end

  # execute "cd #{path}"

  execute "git clone https://github.com/mwrock/packer-templates.git" do
    cwd path
    not_if "stat #{::File.join(path, 'packer-templates')}"
  end

  # execute "cd #{git_path}"

  execute "/packer build -force -only virtualbox-iso vbox-2012r2.json" do
    cwd git_path
    not_if "stat #{::File.join(git_path, 'windows2012r2min-virtualbox.box')}"
  end

  execute "ls windows2012r2min-virtualbox.box" do
    cwd git_path
  end

  execute "vagrant box add windows-2012r2 windows2012r2min-virtualbox.box" do
    cwd git_path
    not_if 'vagrant box list | grep windows-2012r2'
  end

  execute "vagrant box list"

end
