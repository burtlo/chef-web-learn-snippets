#
# Cookbook Name:: test_your_infra_code
# Recipe:: verify-style-guide
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

default_recipe = '~/learn-chef/cookbooks/webserver_test/recipes/default.rb'
rubocop_file = '~/learn-chef/cookbooks/webserver_test/.rubocop.yml'

with_snippet_options(lesson: 'verify-your-code-adheres-to-the-style-guide')

# 1. Use RuboCop to make your code easier to read and maintain

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'use-rubocop') do

  snippet_code_block 'default-4-rhel' do
    file_path default_recipe
    source_filename 'default-4-rhel.rb'
  end

  snippet_execute 'cd-webserver_test-3' do
    cwd '~'
    command 'cd ~/learn-chef/cookbooks/webserver_test'
  end

  snippet_execute 'rubocop-recipes-1' do
    command 'rubocop ./recipes'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'default-5-rhel' do
    file_path default_recipe
    source_filename 'default-5-rhel.rb'
  end

  snippet_execute 'rubocop-recipes-2' do
    command 'rubocop ./recipes'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'default-6-rhel' do
    file_path default_recipe
    source_filename 'default-6-rhel.rb'
  end

  snippet_execute 'rubocop-recipes-3' do
    command 'rubocop ./recipes'
  end

  snippet_code_block 'default-7-rhel' do
    file_path default_recipe
    source_filename 'default-7-rhel.rb'
  end

  snippet_execute 'rubocop-recipes-4' do
    command 'rubocop ./recipes'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'rubocop-yml' do
    file_path rubocop_file
    source_filename '.rubocop.yml'
  end

  snippet_execute 'rubocop-recipes-5' do
    command 'rubocop ./recipes'
  end

end

# 2. Use Foodcritic to identify better usage patterns

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'use-foodcritic') do

  snippet_code_block 'default-8-rhel' do
    file_path default_recipe
    source_filename 'default-8-rhel.rb'
  end

  snippet_execute 'foodcritic-recipes-1' do
    command 'foodcritic ./recipes/*'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'default-3-2-rhel' do
    file_path default_recipe
    source_filename 'default-3-rhel.rb'
  end

  snippet_execute 'foodcritic-recipes-2' do
    command 'foodcritic ./recipes/*'
  end

  snippet_code_block 'default-9-rhel' do
    file_path default_recipe
    source_filename 'default-9-rhel.rb'
  end

  snippet_execute 'foodcritic-recipes-3' do
    command 'foodcritic ./recipes/*'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'default-3-3-rhel' do
    file_path default_recipe
    source_filename 'default-3-rhel.rb'
  end

  snippet_execute 'foodcritic-recipes-4' do
    command 'foodcritic ./recipes/*'
  end

end
