#
# Cookbook Name:: workstation
# Recipe:: vagrant
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe "workstation::vagrant_#{node['platform']}"
