#
# Cookbook Name:: test_your_infra_code
# Recipe:: verify-resources-defined
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

default_spec = '~/learn-chef/cookbooks/webserver_test/spec/unit/recipes/default_spec.rb'

default_recipe = '~/learn-chef/cookbooks/webserver_test/recipes/default.rb'

with_snippet_options(lesson: 'verify-resources-properly-defined')

# 1. Write ChefSpec tests that verify the current web server configuration

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'write-chefspec-tests') do

  snippet_execute 'cd-webserver_test-2' do
    cwd '~'
    command 'cd ~/learn-chef/cookbooks/webserver_test'
  end

  snippet_execute 'tree-spec-dir' do
    command 'tree spec'
  end

  snippet_code_block 'default_spec-0' do
    file_path default_spec
    content lazy { ::File.read(::File.expand_path(default_spec)) }
  end

  snippet_code_block 'default_spec-1' do
    file_path default_spec
    source_filename 'default_spec-1-rhel.rb'
  end

  snippet_execute 'chef-exec-rspec-1' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
  end

end

# 2. Define the CentOS context

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'define-the-context') do

  snippet_code_block 'default_spec-2-structure' do
    file_path default_spec
    source_filename 'default_spec-2-structure-rhel.rb'
  end

  snippet_code_block 'default_spec-2' do
    file_path default_spec
    source_filename 'default_spec-2-rhel.rb'
  end

  execute 'temp-kitchen-create' do
    cwd ::File.expand_path('~/learn-chef/cookbooks/webserver_test')
    command 'kitchen create'
  end

  snippet_execute 'kitchen-exec-centos-release' do
    command "kitchen exec --command 'cat /etc/centos-release'"
    remove_lines_matching [/locale/]
  end

  execute 'temp-kitchen-destroy' do
    cwd ::File.expand_path('~/learn-chef/cookbooks/webserver_test')
    command 'kitchen destroy'
  end

  snippet_execute 'chef-exec-rspec-2' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
  end

end

# 3. Write ChefSpec tests for the Ubuntu web server configuration

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'write-chefspec-tests-for-ubuntu') do

  snippet_code_block 'default_spec-3' do
    file_path default_spec
    source_filename 'default_spec-3-rhel.rb'
  end

  snippet_execute 'chef-exec-rspec-3' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_execute 'chef-exec-rspec-4' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
    trim_stdout ({
       from: /^\.+F+/,
       to: /\d* examples, \d* failures/m
    })
    ignore_failure true # in fact, we expect this to fail!
  end

end

# 4. Revise the webserver_test cookbook to support Ubuntu

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'revise-cookbook-for-ubuntu') do

  snippet_code_block 'default-3-rhel' do
    file_path default_recipe
    source_filename 'default-3-rhel.rb'
  end

  snippet_execute 'chef-exec-rspec-5' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
  end

end

# 5. Refactor the tests to reduce repeated code

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'refactor-reduce-repeated-code') do

  snippet_code_block 'default_spec-4' do
    file_path default_spec
    source_filename 'default_spec-4-rhel.rb'
  end

  snippet_execute 'chef-exec-rspec-6' do
    command 'chef exec rspec --color spec/unit/recipes/default_spec.rb'
  end

end
