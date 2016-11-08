#
# Cookbook Name:: learn_the_basics_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'tree'

with_snippet_options(
  tutorial: 'learn-the-basics',
  platform: 'ubuntu',
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character']
  ) do

include_recipe 'learn_the_basics_ubuntu::install-chefdk'
include_recipe 'learn_the_basics_ubuntu::configure-a-resource'
include_recipe 'learn_the_basics_ubuntu::configure-a-package-and-service'
include_recipe 'learn_the_basics_ubuntu::make-your-recipe-more-manageable'

unless %w[vagrant virtualbox].include? node['snippets']['virtualization']
  snippet_config 'learn-the-basics'
end

end
