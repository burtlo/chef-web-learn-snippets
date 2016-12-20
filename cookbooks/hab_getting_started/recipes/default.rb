#
# Cookbook Name:: hab_getting_started
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

case node['platform']
when 'ubuntu'
  platform = 'linux'
  os_name = "Ubuntu #{node['platform_version']}"
when 'windows'
  platform = 'windows'
  os_name = "Windows Server 2012 R2"
when 'mac_os_x'
  platform = 'mac'
  os_name = "Mac OS X #{node['platform_version']}" # TODO: Verify version comes out like you expect
end

case node['snippets']['virtualization']
when 'vmware_fusion'
  virtualization = 'VMware Fusion'
end

with_snippet_options(
  tutorial: 'hab_getting_started',
  platform: node['platform'],
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character']
  ) do

  include_recipe "hab_getting_started::prerequisites_#{platform}"
  include_recipe "hab_getting_started::set_up_env_#{platform}"
  include_recipe "hab_getting_started::create_first_plan_#{platform}"

  snippet_config 'hab_getting_started' do
    variables lazy {
      ({
        :os_name => os_name,
        :virtualization => virtualization,
        :hab_version => node.run_state['hab_version']
      })
    }
  end
end
