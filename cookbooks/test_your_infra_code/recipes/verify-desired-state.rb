#
# Cookbook Name:: test_your_infra_code
# Recipe:: verify-desired-state
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

default_test = '~/learn-chef/cookbooks/webserver_test/test/recipes/default_test.rb'

default_recipe = '~/learn-chef/cookbooks/webserver_test/recipes/default.rb'

with_snippet_options(lesson: 'verify-desired-state')

# 1. Create a web server cookbook

with_snippet_options(cwd: '~', step: 'create-the-web-server-cookbook') do
  snippet_execute 'cd-learn-chef' do
    command 'cd ~/learn-chef'
  end
end

with_snippet_options(cwd: '~/learn-chef', step: 'create-the-web-server-cookbook') do
  snippet_execute 'chef-generate-cookbook' do
    command 'chef generate cookbook cookbooks/webserver_test'
    not_if 'stat ~/learn-chef/cookbooks/webserver_test'
  end

  snippet_execute 'tree-test-dir' do
    command 'tree cookbooks/webserver_test/test'
  end

  # TODO: Can't right now because of https://github.com/chef/chef-dk/issues/964
  # snippet_code_block 'default-test' do
  #   file_path default_test
  #   content lazy { ::File.read(::File.expand_path(default_test)) }
  # end

end

# 2. Write the first test

with_snippet_options(cwd: '~/learn-chef', step: 'write-the-first-test') do

  snippet_code_block 'default_test-1' do
    file_path default_test
    source_filename 'default_test-1-rhel.rb'
  end

end

# 3. Run the test on a CentOS virtual machine

with_snippet_options(cwd: '~/learn-chef', step: 'run-the-first-test') do

  snippet_code_block 'kitchen-yml' do
    file_path '~/learn-chef/cookbooks/webserver_test/.kitchen.yml'
    source_filename '.kitchen-rhel.yml'
  end

  snippet_execute 'cd-webserver_test-1' do
    command 'cd ~/learn-chef/cookbooks/webserver_test'
  end

  snippet_execute 'kitchen-list-1' do
    cwd '~/learn-chef/cookbooks/webserver_test'
    command 'kitchen list'
  end

  snippet_execute 'kitchen-verify-1' do
    cwd '~/learn-chef/cookbooks/webserver_test'
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
    ignore_failure true # in fact, we expect this to fail!
  end

end

# 4. Write just enough code to make the test pass

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'make-first-test-pass') do

  snippet_code_block 'default-1-rhel' do
    file_path default_recipe
    source_filename 'default-1-rhel.rb'
  end

end

# 5. Apply and verify the configuration

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'apply-and-verify-the-configuration') do

  snippet_execute 'kitchen-converge-1' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#########/]
  end

  snippet_execute 'kitchen-verify-2' do
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

  snippet_execute 'kitchen-list-2' do
    command 'kitchen list'
  end

end

# 6. Write the remaining tests

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'write-the-remaining-tests') do

  snippet_code_block 'default_test-2' do
    file_path default_test
    source_filename 'default_test-2-rhel.rb'
  end

end


# 7. Watch the remaining tests fail

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'write-the-remaining-tests') do

  snippet_execute 'kitchen-verify-3' do
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
    ignore_failure true # in fact, we expect this to fail!
  end

end

# 8. Write just enough code to make the remaining tests pass

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'make-remaining-tests-pass') do

  snippet_code_block 'default-2-rhel' do
    file_path default_recipe
    source_filename 'default-2-rhel.rb'
  end

end

## 9. Apply and verify the updated configuration

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'apply-and-verify-updated-configuration') do

  snippet_execute 'kitchen-converge-2' do
    command 'kitchen converge'
    remove_lines_matching [/locale/, /#########/]
  end

  snippet_execute 'kitchen-verify-4' do
    command 'kitchen verify'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

end

## 10. Verify your configuration on a clean instance

with_snippet_options(cwd: '~/learn-chef/cookbooks/webserver_test', step: 'verify-on-clean-instance') do

  snippet_execute 'kitchen-test-1' do
    command 'kitchen test'
    remove_lines_matching [/locale/, /#/, /Progress:/, /Estimated time remaining/]
  end

  snippet_execute 'kitchen-list-3' do
    command 'kitchen list'
  end

end
