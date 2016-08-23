#
# Cookbook Name:: learn_the_basics_windows
# Recipe:: make-your-recipe-more-manageable
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'make-your-recipe-more-manageable')

# 1. Create a cookbook

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'create-a-cookbook') do

  snippet_execute 'mkdir-cookbooks' do
    command 'mkdir cookbooks'
    ignore_failure true
  end

end

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'create-a-cookbook') do

  snippet_execute 'chef-generate-cookbook' do
    command 'chef generate cookbook cookbooks\learn_chef_iis'
  end

  snippet_execute 'tree-cookbook' do
    command 'tree /F /A cookbooks'
  end

end

# 2. Create a template

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'create-a-template') do

  snippet_execute 'chef-generate-template' do
    command 'chef generate template cookbooks\learn_chef_iis Default.htm'
  end

  snippet_execute 'tree-template' do
    command 'tree /F /A cookbooks'
  end

  snippet_code_block 'index-1' do
    file_path 'C:\Users\Administrator\cookbooks\learn_chef_iis\templates\Default.htm.erb'
    source_filename 'Default-1.htm.erb'
    language 'html-Win32'
  end

end

# 3. Update the recipe to reference the HTML template

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'update-the-recipe-to-reference-the-html-template') do

  snippet_code_block 'default-1' do
    file_path 'C:\Users\Administrator\cookbooks\learn_chef_iis\recipes\default.rb'
    source_filename 'default-1.rb'
    language 'ruby-Win32'
  end

end

# 4. Run the cookbook

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'run-the-cookbook') do

  snippet_execute 'cookbook-ccr-1' do
    command "chef-client --local-mode --runlist 'recipe[learn_chef_iis]'"
  end

  snippet_execute 'cookbook-iwr-localhost' do
    command '(Invoke-WebRequest -UseBasicParsing localhost).Content'
  end

end
