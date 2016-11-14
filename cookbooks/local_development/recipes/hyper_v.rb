#
# Cookbook Name:: hyper_v
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

iso_file = '9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
iso_url = "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/#{iso_file}"

reboot 'now' do
  action :nothing
  reason 'Hyper-V requires reboot.'
  delay_mins 0
end

with_snippet_options(
  tutorial: 'local-development',
  lesson: 'set-up-your-workstation',
  platform: 'windows',
  virtualization: 'hyper-v',
  prompt_character: node['snippets']['prompt_character'],
  shell: 'ps',
  cwd: '~',
  ) do

  include_recipe 'manage_a_node::workstation'

  with_snippet_options(step: 'install-hyper-v-driver') do
    snippet_execute 'install-kitchen-hyperv' do
      command 'chef gem install kitchen-hyperv'
      not_if 'chef gem list | grep kitchen-hyperv'
    end
  end

  with_snippet_options(step: 'enable-the-hyper-v-windows-feature') do
    snippet_execute 'enable-hyper-v' do
      command 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart'
      only_if "(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V).State -eq 'Disabled'"
      guard_interpreter :powershell_script
      notifies :reboot_now, 'reboot[now]', :immediately
    end

    snippet_execute 'verify-hyper-v-1' do
      command 'Get-Command -Module Hyper-V'
      #not_if ''
    end

    snippet_execute 'import-servermanager' do
      command 'Import-Module ServerManager'
      #not_if ''
    end

    snippet_execute 'add-hyper-v-tools' do
      command 'Add-WindowsFeature RSAT-Hyper-V-Tools -IncludeAllSubFeature'
      #not_if ''
    end

    snippet_execute 'verify-hyper-v-2' do
      command 'Get-Command -Module Hyper-V'
      #not_if ''
    end
  end

  with_snippet_options(step: 'create-a-base-virtual-machine') do
    snippet_execute 'mkdir-c-iso' do
      command 'mkdir C:\iso'
      not_if 'stat C:\iso'
    end

    # TODO: BITS must be run interactively :(
    # snippet_execute 'download-windows-iso' do
    #   command "Start-BitsTransfer -Source #{iso_url} -Destination C:\\iso"
    #   not_if "stat C:\\iso\\#{iso_file}"
    # end
    remote_file "C:\\iso\\#{iso_file}" do
      source iso_url
      action :create
      not_if "stat C:\\iso\\#{iso_file}"
    end

    snippet_execute 'create-a-hyper-v-switch' do
      command 'Get-NetAdapter'
      #not_if ''
    end

    #snippet_execute 'get-netadapter' do
    #  command '$net_adapter = Get-NetAdapter -Name Ethernet'
      #not_if ''
    #end

    snippet_execute 'create-vmswitch' do
      command "New-VMSwitch -Name ExternalSwitch -NetAdapterName Ethernet -AllowManagementOS $True -Notes 'Provide public network access to VMs'"
      #not_if ''
    end

    snippet_execute 'mkdir-c-hyper-v' do
      command 'mkdir C:\Hyper-V'
      not_if 'stat C:\Hyper-V'
    end

    # snippet_execute 'mkdir-c-hyper-v' do
    #   command 'mkdir C:\Hyper-V'
    #   not_if 'stat C:\Hyper-V'
    # end
  end



  # execute 'vagrant plugin install vagrant-winrm' do
  #   not_if 'vagrant plugin list | grep vagrant-winrm'
  # end
  #
  # path = ::File.expand_path('~/learn-chef')
  # git_path = ::File.join(path, 'packer-templates')
  #
  # execute "mkdir -p #{path}" do
  #   not_if "stat #{path}"
  # end
  #
  # # execute "cd #{path}"
  #
  # execute "git clone https://github.com/mwrock/packer-templates.git" do
  #   cwd path
  #   not_if "stat #{::File.join(path, 'packer-templates')}"
  # end
  #
  # # execute "cd #{git_path}"
  #
  # execute "/packer build -force -only virtualbox-iso vbox-2012r2.json" do
  #   cwd git_path
  #   not_if "stat #{::File.join(git_path, 'windows2012r2min-virtualbox.box')}"
  # end
  #
  # execute "ls windows2012r2min-virtualbox.box" do
  #   cwd git_path
  # end
  #
  # execute "vagrant box add windows-2012r2 windows2012r2min-virtualbox.box" do
  #   cwd git_path
  #   not_if 'vagrant box list | grep windows-2012r2'
  # end
  #
  # execute "vagrant box list"

end
