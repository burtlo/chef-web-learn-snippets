#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: make-your-recipe-more-manageable
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'make-your-recipe-more-manageable')

# 1. Create a cookbook

with_snippet_options(cwd: '~/chef-repo', step: 'create-a-cookbook') do

  snippet_execute 'mkdir-cookbooks' do
    command 'mkdir cookbooks'
  end

end

with_snippet_options(cwd: '~/chef-repo', step: 'create-a-cookbook') do

  snippet_execute 'chef-generate-cookbook' do
    command 'chef generate cookbook cookbooks/learn_chef_httpd'
    trim_stdout ({
      from: /\s+\* template\[\/root\/chef-repo\/cookbooks\/learn_chef_httpd\/metadata\.rb.*?restore selinux security context/m,
      to: /\* directory\[\/root\/chef-repo\/cookbooks\/learn_chef_httpd\/recipes\] action create.*?restore selinux security context/m
      })
  end

  snippet_execute 'tree-cookbook' do
    command 'tree cookbooks'
  end

end

# 2. Create a template

with_snippet_options(cwd: '~/chef-repo', step: 'create-a-template') do

  snippet_execute 'chef-generate-template' do
    command 'chef generate template cookbooks/learn_chef_httpd index.html'
  end

  snippet_execute 'tree-template' do
    command 'tree cookbooks'
  end

  snippet_code_block 'index-1' do
    file_path '~/chef-repo/cookbooks/learn_chef_httpd/templates/default/index.html.erb'
    source_filename 'index-1.html.erb'
  end

end

# 3. Update the recipe to reference the HTML template

with_snippet_options(cwd: '~/chef-repo', step: 'update-the-recipe-to-reference-the-html-template') do

  snippet_code_block 'default-1' do
    file_path '~/chef-repo/cookbooks/learn_chef_httpd/recipes/default.rb'
    source_filename 'default-1.rb'
  end

end

# 4. Run the cookbook

with_snippet_options(cwd: '~/chef-repo', step: 'run-the-cookbook') do

  snippet_execute 'cookbook-ccr-1' do
    command "sudo chef-client --local-mode --runlist 'recipe[learn_chef_httpd]'"
  end

  snippet_execute 'cookbook-curl-localhost' do
    command 'curl localhost'
  end

end
