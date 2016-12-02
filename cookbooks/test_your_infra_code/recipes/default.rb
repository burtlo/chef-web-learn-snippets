#
# Cookbook Name:: test_your_infra_code
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

snippet_options = {
  tutorial: 'test-your-infrastructure-code',
  platform: 'rhel',
  virtualization: node['snippets']['virtualization'],
  prompt_character: node['snippets']['prompt_character']
}
# On Windows, ensure we're running using PowerShell.
if node['platform'] == 'windows'
  snippet_options[:shell] = 'ps'
end

# Install git
unless node['platform'] == 'windows'
  git_client 'default' do
    action :install
  end
end

with_snippet_options(snippet_options) do

# Write config file.
snippet_config 'test-your-infrastructure-code'

include_recipe 'test_your_infra_code::prerequisites'
include_recipe 'test_your_infra_code::verify-desired-state'
include_recipe 'test_your_infra_code::verify-resources-defined'
include_recipe 'test_your_infra_code::verify-style-guide'
include_recipe 'test_your_infra_code::exercise-email'
include_recipe 'test_your_infra_code::refactor-web-app'
include_recipe 'test_your_infra_code::create-custom-resource'

end
