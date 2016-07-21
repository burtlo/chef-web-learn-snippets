#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: configure-a-resource
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(snippet_path: File.join(snippets_root, 'learn-the-basics/rhel/configure-a-resource'))

# 1. Set up your working directory

with_snippet_options(cwd: '~', snippet_file: 'set-up-your-working-directory') do

  snippet_execute 'mkdir-chef-repo' do
    command 'mkdir ~/chef-repo'
    not_if 'stat ~/chef-repo'
  end

  snippet_execute 'cd-chef-repo' do
    command 'cd ~/chef-repo'
  end

end

# 2. Create the MOTD file

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'create-the-motd-file') do

  snippet_code_block 'hello-1' do
    file_name '~/chef-repo/hello.rb'
    source_file 'hello-1.rb'
  end

  snippet_execute 'ccr-1' do
    command 'chef-client --local-mode hello.rb'
  end

  snippet_execute 'more-tmp-motd' do
    command 'more /tmp/motd'
    trim_stdout ({ from: /^\:/, to: /\:$\n/, replace_with: '' })
  end

  snippet_execute 'ccr-2' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 3. Update the MOTD file's contents

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'update-the-motd-files-contents') do

  snippet_code_block 'hello-2' do
    file_name '~/chef-repo/hello.rb'
    source_file 'hello-2.rb'
  end

  snippet_execute 'ccr-3' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 4. Ensure the MOTD file's contents are not changed by anyone else

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'ensure-the-motd-files-contents-are-not-changed-by-anyone-else') do

  snippet_execute 'echo-robots' do
    command "echo 'hello robots' > /tmp/motd"
  end

  snippet_execute 'ccr-4' do
    command 'chef-client --local-mode hello.rb'
  end

end

# 5. Delete the MOTD file

with_snippet_options(cwd: '~/chef-repo', snippet_file: 'delete-the-motd-file') do

  snippet_code_block 'goodbye' do
    file_name '~/chef-repo/goodbye.rb'
    source_file 'goodbye.rb'
  end

  snippet_execute 'ccr-5' do
    command 'chef-client --local-mode goodbye.rb'
  end

  snippet_execute 'more-tmp-motd-2' do
    command 'more /tmp/motd'
  end
end
