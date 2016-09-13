#
# Cookbook Name:: learn_chef_httpd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
package 'httpd'

service 'httpd' do
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
  mode '0644'
  owner 'web_admin'
  group 'web_admin'
end
