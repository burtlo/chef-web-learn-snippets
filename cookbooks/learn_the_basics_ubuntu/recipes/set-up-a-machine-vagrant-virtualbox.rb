#
# Cookbook Name:: learn_the_basics_ubuntu
# Recipe:: set-up-a-machine-vagrant-virtualbox
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

with_snippet_options(
  tutorial: 'learn-the-basics',
  platform: 'ubuntu',
  virtualization: 'virtualbox') do

  with_snippet_options(lesson: 'set-up-a-machine-to-manage')

  include_recipe 'workstation::chefdk' if node['platform'] == 'windows'

  # 1. Install VirtualBox

  with_snippet_options(cwd: '~', step: 'install-virtualbox') do
    snippet_execute 'vboxmanage--version' do
      command 'VBoxManage --version'
    end
  end

  # 2. Install Vagrant

  with_snippet_options(cwd: '~', step: 'install-vagrant') do
    snippet_execute 'vagrant--version' do
      command 'vagrant --version'
    end
  end

  # 3. Download an Ubuntu 14.04 Vagrant box

  with_snippet_options(cwd: '~', step: 'download-a-ubuntu-1404-vagrant-box') do
    snippet_execute 'vagrant-box-add-ubuntu-1404' do
      command 'vagrant box add bento/ubuntu-14.04 --provider=virtualbox'
      remove_lines_matching /^.+?\d+:\d+:\d+.+?\n/
      ignore_failure true
    end
  end

  # 4. Bring up a Ubuntu 14.04 instance

  with_snippet_options(cwd: '~', step: 'bring-up-a-ubuntu-1404-instance') do
    snippet_execute 'vagrant-init' do
      command 'vagrant init bento/ubuntu-14.04'
      ignore_failure true
    end
    snippet_execute 'vagrant-up' do
      command 'vagrant up'
      ignore_failure true
    end
  end

  # Z. Windows workstation only - verify your SSH client

  if node['platform_family'] == 'windows'
    with_snippet_options(cwd: '~', step: 'verify-your-ssh-client', shell: 'ps') do
      snippet_execute 'git--version' do
        command 'git --version'
      end
      snippet_execute 'ssh-no-args' do
        command 'ssh'
        ignore_failure true
      end
    end
  end

  # Connect

  with_snippet_options(cwd: '~', step: 'connect-to-instance') do
    snippet_execute 'vagrant-ssh' do
      command 'vagrant ssh'
    end
  end

  # Cleaning up

  with_snippet_options(cwd: '~', step: 'cleaning-up') do
    snippet_execute 'vagrant-destroy' do
      command 'vagrant destroy --force'
    end
  end

  vagrant_ubuntu_version = '/vagrant/vagrant-ubuntu.version'
  virtualbox_ubuntu_version = '/vagrant/virtualbox-ubuntu.version'
  snippet_config 'learn-the-basics' do
    variables lazy {
      ({
        :vagrant_ubuntu_version => ::File.read(vagrant_ubuntu_version),
        :virtualbox_ubuntu_version => ::File.read(virtualbox_ubuntu_version)
      })
    }
  end

end

# Play the rest of the scenario on a VM.

case node['platform_family']
when 'windows'
  solo = 'C:\vagrant-chef\solo.rb'
  tmp = 'C:\tmp'
  share = 'C:\vagrant'
else
  solo = '/tmp/vagrant-chef/solo.rb'
  tmp = '/tmp'
  share = '/vagrant'
end

directory tmp

unless node['platform'] == 'windows'
  workstation_vagrantfile tmp do
    source_template 'Vagrantfile.virtualbox.erb'
    cookbook_path ::IO.readlines(solo).grep(/^cookbook_path\s+\[\"(.+)\"\]$/m){$1}[0]
  end

  execute 'copy snippet output from vm' do
    command "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i #{tmp}/.vagrant/machines/ubuntu-14.04/virtualbox/private_key -r vagrant@192.168.33.33:/vagrant/snippets/learn-the-basics #{share}/snippets/"
  end
end
