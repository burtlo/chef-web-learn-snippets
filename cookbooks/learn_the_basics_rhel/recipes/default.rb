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

# Write config file.
snippet_config 'learn-the-basics'

include_recipe 'learn_the_basics_rhel::install-chefdk'
include_recipe 'learn_the_basics_rhel::configure-a-resource'
include_recipe 'learn_the_basics_rhel::configure-a-package-and-service'
include_recipe 'learn_the_basics_rhel::make-your-recipe-more-manageable'

end
