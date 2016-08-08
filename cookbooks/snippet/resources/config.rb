include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :tutorial, String, required: true, name_property: true
property :platform, [ String, nil ], required: false, default: nil
property :virtualization, [ String, nil ], required: false, default: nil

def initialize(*args)
  super
  @platform ||= snippet_options[:platform]
  @virtualization ||= snippet_options[:virtualization]
end

action :write do
  # This is the file that holds the config file.
  config_filename = ::File.join(node['snippets']['root_directory'], tutorial, platform, virtualization, 'machine_config.md')

  # Ensure directory exists.
  directory ::File.dirname(config_filename) do
    recursive true
  end

  # Write config file.
  template config_filename do
    source 'machine_config.md.erb'
  end
end
