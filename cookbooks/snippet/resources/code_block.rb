include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :id, String, required: true, name_property: true
property :file_name, String, required: true
property :snippet_path, [ String, nil ], default: nil
property :snippet_file, [ String, nil ], default: nil
property :source_file, String, required: true

def initialize(*args)
  super
  @snippet_path ||= snippet_options[:snippet_path]
  @snippet_file ||= snippet_options[:snippet_file]
end

action :create do
  # Copy the file locally.
  directory ::File.dirname(file_name) do
    recursive true
  end

  cookbook_file ::File.expand_path(file_name) do
    source source_file
  end

  # This is the file that holds the manifest.
  manifest_filename = ::File.join(snippet_path, snippet_file) + '.yml'

  # Generate a base filename to store the file.
  base_code_filename = make_base_filename(snippet_file + id)

  # Ensure snippet directory exists.
  directory snippet_path do
    recursive true
  end

  # Update the manifest.
  new_item = {
    id: id,
    snippet_tag: "<% code_snippet('#{snippet_file}', '#{id}') %>",
    language: language_from_file_name,
    path: file_name,
    file: code_file(base_code_filename, ::File.extname(file_name))
  }
  manifest = update_manifest(load_manifest(manifest_filename), new_item)

  # Write manifest.
  file manifest_filename do
    content manifest
  end

  # Write codefile snippet.
  cookbook_file ::File.join(snippet_path, code_file(base_code_filename, ::File.extname(file_name))) do
    source source_file
  end
end

# Generates a code filename.
def code_file(base, ext)
  base + ext
end

def language_from_file_name
  language = nil
  case ::File.extname(file_name)
  when '.rb'
    language = 'ruby'
  end

  # Perhaps no extension. Special case based on filename.
  # TODO

  raise "Unknown language for '#{file_name}'." unless language
  language
end
