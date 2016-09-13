#
# Cookbook Name:: manage_a_node
# Recipe:: chef-server-azure-marketplace
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# TODO: This is redundant with chef-server-marketplace. Call the other, but add node attribute for knife.rb below (node_name & client_key)

include_recipe 'manage_a_node::chef-server-aws-marketplace'
