#
# Cookbook Name:: chefspec
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

rspec_command = 'chef exec rspec --color spec/unit/recipes/default_spec.rb'

# 1. Create the web_content cookook
with_snippet_options(step: 'create-the-cookook') do

  snippet_execute 'cd-learn-chef' do
    cwd '~'
    command 'cd ~/learn-chef'
  end

  snippet_execute 'chef-generate-cookbook' do
    cwd '~/learn-chef'
    command 'chef generate cookbook cookbooks/web_content'
  end

  snippet_execute 'cd-web_content-1' do
    cwd '~/learn-chef'
    command 'cd ~/learn-chef/cookbooks/web_content'
  end

end

# 2. Examine at the default test
with_snippet_options(step: 'examine-the-test') do

  snippet_execute 'tree-spec' do
    cwd '~/learn-chef/cookbooks/web_content'
    command 'tree spec'
  end

  snippet_code_block 'default_spec-2' do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb')) }
    write_system_file false
  end

end

# 3. Run ChefSpec
with_snippet_options(step: 'run-chefspec') do

  snippet_execute 'run-rspec-3' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end

# 4. Specify the platform
with_snippet_options(step: 'specify-the-platform') do

  snippet_code_block "default_spec_4" do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    source_filename 'web_content/spec/default_spec_4.rb'
  end

  snippet_execute 'run-rspec-4' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end

# 5. Configure the directory
with_snippet_options(step: 'configure-the-directory') do

  snippet_code_block "default_5" do
    file_path '~/learn-chef/cookbooks/web_content/recipes/default.rb'
    source_filename 'web_content/recipes/default_5.rb'
  end

  snippet_execute 'run-rspec-5' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end
end

# 6. Test the configuration
with_snippet_options(step: 'test-the-configuration') do

  snippet_code_block "default_spec_6" do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    source_filename 'web_content/spec/default_spec_6.rb'
  end

  snippet_execute 'run-rspec-6' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end

# 7. Make the recipe more flexible
with_snippet_options(step: 'make-the-recipe-more-flexible') do

  snippet_execute 'cd-learn-chef-7' do
    cwd '~/learn-chef/cookbooks/web_content'
    command 'cd ~/learn-chef'
  end

  snippet_execute 'chef-generate-attribute' do
    cwd '~/learn-chef'
    command 'chef generate attribute cookbooks/web_content default'
  end

  snippet_code_block "default_attributes_7" do
    file_path '~/learn-chef/cookbooks/web_content/attributes/default.rb'
    source_filename 'web_content/attributes/default_7.rb'
  end

  snippet_code_block "default_7" do
    file_path '~/learn-chef/cookbooks/web_content/recipes/default.rb'
    source_filename 'web_content/recipes/default_7.rb'
  end

  snippet_code_block "default_spec_7" do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    source_filename 'web_content/spec/default_spec_7.rb'
  end

  snippet_execute 'cd-web_content-7' do
    cwd '~/learn-chef'
    command 'cd ~/learn-chef/cookbooks/web_content'
  end

  snippet_execute 'run-rspec-7' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end

# 8. Resolve a test failure
with_snippet_options(step: 'resolve-a-failure') do

  snippet_code_block "default_8a" do
    file_path '~/learn-chef/cookbooks/web_content/recipes/default.rb'
    source_filename 'web_content/recipes/default_8a.rb'
  end

  snippet_execute 'run-rspec-8a' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
    ignore_failure true # we expect to fail
  end

  snippet_code_block "default_attributes_8" do
    file_path '~/learn-chef/cookbooks/web_content/attributes/default.rb'
    source_filename 'web_content/attributes/default_8.rb'
  end

  snippet_code_block "default_8b" do
    file_path '~/learn-chef/cookbooks/web_content/recipes/default.rb'
    source_filename 'web_content/recipes/default_8b.rb'
  end

  snippet_code_block "default_spec_8" do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    source_filename 'web_content/spec/default_spec_8.rb'
  end

  snippet_execute 'run-rspec-8b' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end

# 9. Refactor your tests
with_snippet_options(step: 'refactor-your-tests') do

  snippet_code_block 'default_spec-9a' do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    content lazy { ::File.read(::File.expand_path('~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb')) }
    write_system_file false
  end

  snippet_code_block "default_spec_9b" do
    file_path '~/learn-chef/cookbooks/web_content/spec/unit/recipes/default_spec.rb'
    source_filename 'web_content/spec/default_spec_9b.rb'
  end

  snippet_execute 'run-rspec-9' do
    cwd '~/learn-chef/cookbooks/web_content'
    command rspec_command
    remove_lines_matching [/WARN -- : You are setting a key that conflicts/]
  end

end
