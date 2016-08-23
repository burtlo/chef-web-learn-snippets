#
# Cookbook Name:: learn_the_basics_windows
# Recipe:: configure-a-package-and-service
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'configure-a-package-and-service')

# 1. Install IIS

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'install-iis') do

  snippet_code_block 'webserver-1' do
    file_path 'C:\Users\Administrator\webserver.rb'
    source_filename 'webserver-1.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'package-ccr-1' do
    command 'chef-client --local-mode webserver.rb'
  end

  snippet_execute 'package-ccr-2' do
    command 'chef-client --local-mode webserver.rb'
  end

end

# 2. Start the World Wide Web Publishing Service

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'start-the-world-wide-web-publishing-service') do

  snippet_code_block 'webserver-2' do
    file_path 'C:\Users\Administrator\webserver.rb'
    source_filename 'webserver-2.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'package-ccr-3' do
    command 'chef-client --local-mode webserver.rb'
  end

end

# 3. Configure the home page

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'add-a-home-page') do

  snippet_code_block 'webserver-3' do
    file_path 'C:\Users\Administrator\webserver.rb'
    source_filename 'webserver-3.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'package-ccr-4' do
    command 'chef-client --local-mode webserver.rb'
  end

end

# 4. Confirm your web site is running

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'confirm-your-web-site-is-running') do

  snippet_execute 'iwr-localhost' do
    command '(Invoke-WebRequest -UseBasicParsing localhost).Content'
  end

end
