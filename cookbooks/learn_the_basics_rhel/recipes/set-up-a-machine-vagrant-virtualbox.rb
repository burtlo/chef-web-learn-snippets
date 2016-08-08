#
# Cookbook Name:: learn_the_basics_rhel
# Recipe:: set-up-a-machine-vagrant-virtualbox
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
# if node['platform'] == 'windows'
#   execute 'vagrant plugin install vagrant-vbguest' do
#     not_if 'vagrant plugin list | findstr vagrant-vbguest'
#   end
# end

with_snippet_options(
  tutorial: 'learn-the-basics',
  platform: 'rhel',
  virtualization: 'virtualbox') do

  with_snippet_options(lesson: 'set-up-a-machine-to-manage')

  include_recipe 'workstation::chefdk' if node['platform'] == 'windows'

  # 1. Install VirtualBox

  # if node['platform'] == 'windows'
  #   powershell_script 'add-virtualbox-to-path' do
  #     code <<-EOH
  #     $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
  #     $vbox_path = "C:\\Program Files\\Oracle\\VirtualBox"
  #     [Environment]::SetEnvironmentVariable("PATH", "$path;$vbox_path", "Machine")
  #     $env:Path = [System.Environment]::GetEnvironmentVariable("PATH","Machine")
  #     EOH
  #   end
  # end
  # with_snippet_options(cwd: '~', step: 'silly') do
  #   snippet_execute 'billy' do
  #     command "[Environment]::GetEnvironmentVariable('PATH', 'Machine')"
  #     shell 'powershell'
  #   end
  # end

  with_snippet_options(cwd: '~', step: 'install-virtualbox') do
    snippet_execute 'vboxmanage--version' do
      command 'VBoxManage --version'
    end
  end
  # if node['platform'] == 'windows'
  #   with_snippet_options(cwd: '~', step: 'install-virtualbox') do
  #     snippet_execute 'vboxmanage--version' do
  #       command '& \"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe\" --version'
  #       shell 'powershell'
  #     end
  #   end
  # else
  #   with_snippet_options(cwd: '~', step: 'install-virtualbox') do
  #     snippet_execute 'vboxmanage--version' do
  #       command 'VBoxManage --version'
  #     end
  #   end
  # end

  # 2. Install Vagrant

  with_snippet_options(cwd: '~', step: 'install-vagrant') do
    snippet_execute 'vagrant--version' do
      command 'vagrant --version'
    end
  end

  # 3. Download a CentOS 7.2 Vagrant box

  with_snippet_options(cwd: '~', step: 'download-a-centos-72-vagrant-box') do
    snippet_execute 'vagrant-box-add-centos-72' do
      command 'vagrant box add bento/centos-7.2 --provider=virtualbox'
      remove_lines_matching /^.+?\d+:\d+:\d+.+?\n/
      abort_on_failure false
    end
  end

  # 4. Bring up a CentOS 7.2 instance

  with_snippet_options(cwd: '~', step: 'bring-up-a-centos-72-instance') do
    snippet_execute 'vagrant-init' do
      command 'vagrant init bento/centos-7.2'
      abort_on_failure false
    end
    snippet_execute 'vagrant-up' do
      command 'vagrant up'
      abort_on_failure false
    end
  end

  # Z. Windows workstation only â€“ verify your SSH client

  if node['platform_family'] == 'windows'
    with_snippet_options(cwd: '~', step: 'verify-your-ssh-client', shell: 'ps') do
      snippet_execute 'git--version' do
        command 'git --version'
      end
      snippet_execute 'ssh-no-args' do
        command 'ssh'
        abort_on_failure false
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
    command "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i #{tmp}/.vagrant/machines/centos-7.2/virtualbox/private_key -r vagrant@192.168.33.33:/vagrant/snippets/learn-the-basics #{share}/snippets/"
  end
end
