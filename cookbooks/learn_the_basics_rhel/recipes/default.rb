#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'tree'

with_snippet_options(
  tutorial: 'learn-the-basics',
  platform: 'rhel',
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe 'learn_the_basics_rhel::install-chefdk'
  include_recipe 'learn_the_basics_rhel::configure-a-resource'
  include_recipe 'learn_the_basics_rhel::configure-a-package-and-service'
  include_recipe 'learn_the_basics_rhel::make-your-recipe-more-manageable'

  if node['platform'] == 'windows'
    #vagrant_windows_version = 'C:/vagrant/vagrant-windows.version'
    #vagrant_ubuntu_version = 'C:/vagrant/vagrant-ubuntu.version'
    #virtualbox_windows_version = 'C:/vagrant/virtualbox-windows.version'
    #virtualbox_ubuntu_version = 'C:/vagrant/virtualbox-ubuntu.version'
  else
    #vagrant_windows_version = '/vagrant/vagrant-windows.version'
    vagrant_ubuntu_version = '/vagrant/vagrant-ubuntu.version'
    #virtualbox_windows_version = '/vagrant/virtualbox-windows.version'
    virtualbox_ubuntu_version = '/vagrant/virtualbox-ubuntu.version'
  end

  unless %w[vagrant virtualbox].include? node['snippets']['virtualization']
    snippet_config 'learn-the-basics'
  end
end
