#
# Cookbook Name:: chef_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe "#{node['chef_server']['environment']}"
