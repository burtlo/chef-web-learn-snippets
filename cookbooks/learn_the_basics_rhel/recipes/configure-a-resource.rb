#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: configure-a-resource
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_path('learn-the-basics/rhel/configure-a-resource')

# 1. Set up your working directory

with_cwd('~') do
  with_snippet_file('set-up-your-working-directory') do

    snippet_execute 'mkdir ~/chef-repo' do
      snippet_id 'mkdir'
      not_if 'stat ~/chef-repo'
    end

    snippet_execute 'cd ~/chef-repo' do
      snippet_id 'cd'
    end

  end
end

# 2. Create the MOTD file

with_cwd('~/chef-repo') do
  with_snippet_file('create-the-motd-file') do

  snippet_code_block '~/chef-repo/hello.rb' do
    source_file 'f1.rb'
  end

  snippet_execute 'chef-client --local-mode hello.rb' do
    snippet_id 'run1'
  end

  snippet_execute 'more /tmp/motd' do
    snippet_id 'more'
    trim_stdout ({ from: /^\:/, to: /\:$\n/, replace_with: '' })
  end

  snippet_execute 'chef-client --local-mode hello.rb' do
    snippet_id 'run2'
  end

  end
end

# 3. Update the MOTD file's contents
