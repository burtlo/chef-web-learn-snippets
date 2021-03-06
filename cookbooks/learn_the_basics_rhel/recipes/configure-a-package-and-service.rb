#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: configure-a-package-and-service
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'configure-a-package-and-service')

# 1. Install the Apache package

with_snippet_options(cwd: '~/chef-repo', step: 'install-the-apache-package') do

  snippet_code_block 'webserver-1' do
    file_path '~/chef-repo/webserver.rb'
    source_filename 'webserver-1.rb'
  end

  snippet_execute 'package-ccr-1' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

  snippet_execute 'package-ccr-2' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 2. Start and enable the Apache service

with_snippet_options(cwd: '~/chef-repo', step: 'start-and-enable-the-apache-service') do

  snippet_code_block 'webserver-2' do
    file_path '~/chef-repo/webserver.rb'
    source_filename 'webserver-2.rb'
  end

  snippet_execute 'package-ccr-3' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 3. Add a home page

with_snippet_options(cwd: '~/chef-repo', step: 'add-a-home-page') do

  snippet_code_block 'webserver-3' do
    file_path '~/chef-repo/webserver.rb'
    source_filename 'webserver-3.rb'
  end

  snippet_execute 'package-ccr-4' do
    command 'sudo chef-client --local-mode webserver.rb'
  end

end

# 4. Confirm your web site is running

with_snippet_options(cwd: '~/chef-repo', step: 'confirm-your-web-site-is-running') do

  snippet_execute 'curl-localhost' do
    command 'curl localhost'
  end

end
