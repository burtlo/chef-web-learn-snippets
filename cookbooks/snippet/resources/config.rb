include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :config_path, String, required: true, name_property: true

action :write do
  # Ensure directory exists.
  directory config_path do
    recursive true
  end

  # This is the file that holds the config file.
  config_filename = ::File.join(config_path, 'machine_config.yml')

  # Update the config file contents.
  conf = node['machine_config']
  conf = conf.to_hash if conf.respond_to?(:to_hash)
  contents = update_config(load_config(config_filename), conf)

  # Write config file.
  file config_filename do
    content contents
  end
end
