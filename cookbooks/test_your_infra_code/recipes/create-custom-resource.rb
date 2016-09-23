#
# Cookbook Name:: test_your_infra_code
# Recipe:: create-custom-resource
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory '~/learn-chef/cookbooks/custom_web' do
  action :delete
  recursive true
end

# Quickstart: Get the custom_web cookbook

with_snippet_options(lesson: 'create-a-custom-resource')

with_snippet_options(step: 'quickstart-custom_web', cwd: '~/learn-chef/cookbooks') do

  # To get started, first move to your ~/learn-chef/cookbooks directory.
  snippet_execute 'cd-learn-chef-cookbooks' do
    cwd '~'
    command 'cd ~/learn-chef/cookbooks'
  end

  # Next, clone the cookbook from GitHub.
  snippet_execute 'git-clone-custom_web' do
    command 'git clone https://github.com/learn-chef/custom_web.git'
    not_if 'stat ~/learn-chef/cookbooks/custom_web'
  end

  # Next, move to the custom_web directory.
  snippet_execute 'cd-learn-chef-cookbooks-custom_web' do
    cwd '~'
    command 'cd ~/learn-chef/cookbooks/custom_web'
  end

  snippet_execute 'chef-exec-rspec-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'chef exec rspec --color'
  end

  snippet_execute 'rubocop-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'rubocop .'
  end

  snippet_execute 'foodcritic-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'foodcritic .'
  end

  snippet_execute 'kitchen-list-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'kitchen list'
  end

  snippet_execute 'kitchen-converge-verify-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'kitchen converge && kitchen verify'
    trim_stdout ({
       from: /^\.+$/m,
       to: /\d* examples, \d* failures/m
    })
  end

  snippet_execute 'kitchen-exec-curl-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command "kitchen exec centos --command 'curl localhost'"
  end

  snippet_execute 'kitchen-destroy-custom_web' do
    cwd '~/learn-chef/cookbooks/custom_web'
    command 'kitchen destroy'
  end

end

# Writing the custom_web_site resource

with_snippet_options(step: 'writing-the-custom_web_site-resource', cwd: '~/learn-chef/cookbooks') do

  # The custom_web_site resource is defined in a file named site.rb.
  snippet_code_block 'site-rb' do
    file_path '~/learn-chef/cookbooks/custom_web/resources/site.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/resources/site.rb')) }
  end

  # To do so, it provides a helper library, located in libraries/helpers.rb, that provides the Apache package and service names for the current platform.
  snippet_code_block 'helpers-rb' do
    file_path '~/learn-chef/cookbooks/custom_web/libraries/helpers.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/libraries/helpers.rb')) }
  end

  # site.rb includes the helper library like this:
  snippet_code_block 'site-rb-include' do
    file_path '~/learn-chef/cookbooks/custom_web/resources/site.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/resources/site.rb')).lines[0] }
    write_system_file false
  end
end

# Testing the custom_web_site resource

with_snippet_options(step: 'testing-the-custom_web_site-resource', cwd: '~/learn-chef/cookbooks') do

  # Its default recipe simply declares a custom_web_site resource using the default properties.
  snippet_code_block 'hello_world_test-default-rb' do
    file_path '~/learn-chef/cookbooks/custom_web/test/cookbooks/hello_world_test/recipes/default.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/test/cookbooks/hello_world_test/recipes/default.rb')) }
  end

  # The ChefSpec test, located at cookbooks/custom_web/spec/unit/recipes/hello_world_spec.rb, validates that the test recipe does not raise errors and runs the custom_web_site resource with the :create action.
  snippet_code_block 'hello_world_test-default-spec-rb' do
    file_path '~/learn-chef/cookbooks/custom_web/spec/unit/recipes/hello_world_spec.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/spec/unit/recipes/hello_world_spec.rb')) }
  end

  # However, this version also verifies the configuration on CentOS and Ubuntu
  snippet_code_block 'hello_world_test-default-test-rb' do
    file_path '~/learn-chef/cookbooks/custom_web/test/recipes/default/default_spec.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/custom_web/test/recipes/default/default_spec.rb')) }
  end

end
