#
# Cookbook Name:: workstation
# Recipe:: hyperv
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

powershell_script 'install-hyper-v-feature' do
  code <<-EOH
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
  EOH
  not_if '(Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V").State -eq "Enabled"'
  notifies :reboot_now, 'reboot[Restart Computer]', :immediately
end

reboot 'Restart Computer' do
  action :nothing
end

powershell_script 'add-windowsfeature-hyper-v-tools' do
  code <<-EOH
  Import-Module ServerManager
  Add-WindowsFeature RSAT-Hyper-V-Tools -IncludeAllSubFeature
  EOH
  not_if '(Get-Command -Module Hyper-V) -eq "True"'
end
