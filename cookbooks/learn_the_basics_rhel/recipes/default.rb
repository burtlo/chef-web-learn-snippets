#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'tree'

# Write config file.
snippet_config File.join(snippets_root, 'learn-the-basics/rhel')

include_recipe 'learn_the_basics_rhel::set-up-your-own-server'
include_recipe 'learn_the_basics_rhel::get-set-up'
include_recipe 'learn_the_basics_rhel::configure-a-resource'
include_recipe 'learn_the_basics_rhel::configure-a-package-and-service'
include_recipe 'learn_the_basics_rhel::make-your-recipe-more-manageable'
