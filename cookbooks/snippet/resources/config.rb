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
  config_filename = ::File.join(node['snippets']['root_directory'], tutorial, platform, virtualization, 'machine_config.yml')

  # Ensure directory exists.
  directory ::File.dirname(config_filename) do
    recursive true
  end

  # Update the config file contents.
  conf = node['machine_config']
  conf = conf.to_hash if conf.respond_to?(:to_hash)
  contents = update_config(load_config(config_filename), conf)

  # Write config file.
  file config_filename do
    content contents
  end
end

# Loads the test config file for the project.
def load_config(filename)
  require 'yaml'
  if ::File.exist?(filename)
    YAML.load_file(filename)
  else
    { build_date: '', machines: [] }
  end
end

# Inserts the new item into the config.
def update_config(config, new_item)
  require 'date'
  config[:build_date] = Date.today.to_s
  config[:machines].delete_if {|h| h[:name] == new_item[:name] } unless config[:machines].empty?
  config[:machines].push new_item
  config[:machines].sort! { |x, y| y[:name] <=> x[:name] }
  config.to_yaml(line_width: -1)
end
