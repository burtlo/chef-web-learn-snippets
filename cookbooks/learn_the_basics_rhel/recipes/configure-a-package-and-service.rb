#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: configure-a-package-and-service
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(snippet_path: File.join(snippets_root, 'learn-the-basics/rhel/configure-a-package-and-service'))

# 1. Install the Apache package

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'install-the-apache-package') do

  snippet_code_block 'webserver-1' do
    file_name '~/chef-repo/webserver.rb'
    source_file 'webserver-1.rb'
  end

  snippet_execute 'package-ccr-1' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

  snippet_execute 'package-ccr-2' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 2. Start and enable the Apache service

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'start-and-enable-the-apache-service') do

  snippet_code_block 'webserver-2' do
    file_name '~/chef-repo/webserver.rb'
    source_file 'webserver-2.rb'
  end

  snippet_execute 'package-ccr-3' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 3. Add a home page

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'add-a-home-page') do

  snippet_code_block 'webserver-3' do
    file_name '~/chef-repo/webserver.rb'
    source_file 'webserver-3.rb'
  end

  snippet_execute 'package-ccr-4' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 4. Confirm your web site is running

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'confirm-your-web-site-is-running') do

  snippet_execute 'curl-localhost' do
    command 'curl localhost'
  end

end
