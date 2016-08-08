#
# Cookbook Name:: workstation
# Recipe:: virtualbox
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe "workstation::virtualbox_#{node['platform']}"
