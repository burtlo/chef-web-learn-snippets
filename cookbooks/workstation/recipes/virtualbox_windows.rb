#
# Cookbook Name:: workstation
# Recipe:: virtualbox_windows
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
chocolatey_package 'virtualbox' do
  action :install
  version node['products']['versions']['virtualbox']['windows']
  notifies :run, 'powershell_script[add-virtualbox-to-path]', :immediately
end

powershell_script 'add-virtualbox-to-path' do
  action :nothing
  code <<-EOH
  $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
  $vbox_path = "C:\\Program Files\\Oracle\\VirtualBox"
  [Environment]::SetEnvironmentVariable("PATH", "$path;$vbox_path", "Machine")
  EOH
end


# url = node['products']['urls']['windows']['virtualbox']
# local_package = "C:\\Users\\vagrant\\Downloads\\VirtualBox.exe"
# extract_dir = "C:\\VBox"
#
# remote_file local_package do
#   source url
#   action :create
#   not_if "ls #{local_package}"
#   notifies :run, 'execute[extract virtualbox package]', :immediately
# end
#
# execute 'extract virtualbox package' do
#   command "#{local_package} --extract --silent --path #{extract_dir}"
#   action :nothing
#   notifies :install, 'windows_package[virtualbox]', :immediately
# end
#
# windows_package 'virtualbox' do
#   source lazy {::Dir["#{extract_dir}/*.msi"].select { |f| f =~ /amd64/}.first}
#   installer_type :msi
#   action :nothing
# end
