#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe "manage_a_node::chef-server-#{node['snippets']['virtualization']}"
