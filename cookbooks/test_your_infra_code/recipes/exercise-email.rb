#
# Cookbook Name:: test_your_infra_code
# Recipe:: exercise-email
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

default_test = '~/learn-chef/cookbooks/email/test/recipes/default_test.rb'
default_recipe = '~/learn-chef/cookbooks/email/recipes/default.rb'
kitchen_yml = '~/learn-chef/cookbooks/email/.kitchen.yml'
metadata_rb = '~/learn-chef/cookbooks/email/metadata.rb'

with_snippet_options(lesson: 'exercise-email')

with_snippet_options(cwd: '~/learn-chef/cookbooks/email', step: 'write-from-spec') do

  snippet_execute 'cd-learn-chef-2' do
    cwd '~'
    command 'cd ~/learn-chef'
  end

  snippet_execute 'chef-generate-cookbook-email' do
    cwd '~/learn-chef'
    command 'chef generate cookbook cookbooks/email'
    not_if 'stat ~/learn-chef/cookbooks/email'
  end

  snippet_code_block 'default_test-1-email' do
    file_path default_test
    source_filename 'default_test-1-email.rb'
  end

  snippet_code_block 'kitchen-email-1-yml' do
    file_path kitchen_yml
    source_filename '.kitchen-email-1-rhel.yml'
  end

  snippet_execute 'cd-email' do
    cwd '~/learn-chef'
    command 'cd ~/learn-chef/cookbooks/email'
  end

  snippet_execute 'kitchen-verify-email-1' do
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
    ignore_failure true # in fact, we expect this to fail!
  end

  snippet_code_block 'metadata-email-rb' do
    file_path metadata_rb
    source_filename 'metadata-email.rb'
  end

  snippet_code_block 'default-1-email-rhel' do
    file_path default_recipe
    source_filename 'default-1-email-rhel.rb'
  end

  snippet_code_block 'kitchen-email-2-yml' do
    file_path kitchen_yml
    source_filename '.kitchen-email-2-rhel.yml'
  end

  snippet_execute 'kitchen-converge-email-1' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

  snippet_execute 'kitchen-verify-email-2' do
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

end
