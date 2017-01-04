#
# Cookbook Name:: hab_getting_started
# Recipe:: set_up_env_linux
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'git'

hab_origin = node['habitat']['origin']

with_snippet_options(lesson: 'set-up-your-environment')

with_snippet_options(cwd: '~', step: 'set-up-hab-bin') do

  snippet_execute 'mkdir-bin' do
    command 'mkdir -p ~/bin'
    ignore_failure true
  end

  ruby_block 'get-hab-directory' do
    block do
      lines = `ls ~`.split("\n")
      hab_directory = lines.grep(/\s*(hab-.+-x86_64-linux)\s*$/){$1}[0]
      node.run_state['hab_directory'] = hab_directory
    end
  end

  snippet_execute 'cp-hab-to-bin' do
    command lazy { "cp ~/#{node.run_state['hab_directory']}/hab ~/bin" }
  end

  snippet_execute 'export-path' do
    command 'export PATH=$PATH:~/bin'
  end
  ENV['PATH'] = ENV['PATH'] + ':~/bin'

  snippet_execute 'export-hab_origin' do
    command "export HAB_ORIGIN=#{hab_origin}"
  end
  ENV['HAB_ORIGIN'] = node['habitat']['origin']

  snippet_execute 'hab-origin-key-generate' do
    command "hab origin key generate #{hab_origin}"
  end

  # HACK: work-around issue where running `hab studio run build` looks under the vagrant user's directory for keys.
  # Error exporting myorigin key
  # STDERR: ✗✗✗
  # ✗✗✗ Crypto error: Error reading key directory /home/vagrant/.hab/cache/keys: No such file or directory (os error 2)
  # ✗✗✗
  directory '/home/vagrant/.hab/cache/keys' do
    recursive true
  end
  ruby_block 'copy-keys' do
    block do
      `cp /hab/cache/keys/* /home/vagrant/.hab/cache/keys`
    end
  end
  # END HACK

  # grab Habitat version so we can display it in the test config.
  ruby_block 'get-hab-version' do
    block do
      lines = `/root/bin/hab --version`.split("\n")
      hab_version = lines.grep(/hab (.+)$/){$1}[0]
      node.run_state['hab_version'] = hab_version
    end
  end

end
