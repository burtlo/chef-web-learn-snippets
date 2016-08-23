#
# Cookbook Name:: learn_the_basics_windows
# Recipe:: configure-a-resource
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(lesson: 'configure-a-resource')

directory 'C:\Users\Administrator'

# 1. Set up your working directory

with_snippet_options(cwd: 'C:\Users\Administrator', step: 'set-up-your-working-directory') do

  snippet_execute 'mkdir-chef-repo' do
    command 'mkdir C:\Users\Administrator\chef-repo'
    ignore_failure true
  end

  snippet_execute 'cd-chef-repo' do
    command 'cd C:\Users\Administrator\chef-repo'
  end

end

# 2. Create the INI file

with_snippet_options(cwd: 'C:\Users\Administrator\chef-repo', step: 'create-the-ini-file') do

  snippet_code_block 'hello-1' do
    file_path 'C:\Users\Administrator\chef-repo\hello.rb'
    source_filename 'hello-1.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'ccr-1' do
    command 'chef-client --local-mode hello.rb'
  end

  snippet_execute 'get-content-settings-ini' do
    command 'Get-Content settings.ini'
  end

  snippet_execute 'ccr-2' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 3. Update the INI file's contents

with_snippet_options(cwd: 'C:\Users\Administrator\chef-repo', step: 'update-the-ini-files-contents') do

  snippet_code_block 'hello-2' do
    file_path 'C:\Users\Administrator\chef-repo\hello.rb'
    source_filename 'hello-2.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'ccr-3' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 4. Ensure the MOTD file's contents are not changed by anyone else

with_snippet_options(cwd: 'C:\Users\Administrator\chef-repo', step: 'ensure-the-ini-files-contents-are-not-changed-by-anyone-else') do

  snippet_execute 'set-content-robots' do
    command "Set-Content C:\\Users\\Administrator\\chef-repo\\settings.ini 'greeting=hello robots'"
  end

  snippet_execute 'ccr-4' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 5. Delete the MOTD file

with_snippet_options(cwd: 'C:\Users\Administrator\chef-repo', step: 'delete-the-motd-file') do

  snippet_code_block 'goodbye' do
    file_path 'C:\Users\Administrator\chef-repo\goodbye.rb'
    source_filename 'goodbye.rb'
    language 'ruby-Win32'
  end

  snippet_execute 'ccr-5' do
    command 'chef-client --local-mode goodbye.rb'
  end

  snippet_execute 'test-path-settings-ini' do
    command 'Test-Path C:\Users\Administrator\chef-repo\settings.ini'
  end
end
