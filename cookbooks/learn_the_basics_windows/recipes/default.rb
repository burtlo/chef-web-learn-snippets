#
# Cookbook Name:: learn_the_basics_windows
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(
  tutorial: 'learn-the-basics',
  platform: 'windows',
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character'],
  shell: 'powershell'
  ) do

# Write config file.
snippet_config 'learn-the-basics'

include_recipe 'learn_the_basics_windows::install-chefdk'
include_recipe 'learn_the_basics_windows::configure-a-resource'
include_recipe 'learn_the_basics_windows::configure-a-package-and-service'
include_recipe 'learn_the_basics_windows::make-your-recipe-more-manageable'

end
