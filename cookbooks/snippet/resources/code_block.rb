include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

property :file_name, String, required: true, name_property: true
property :language, [ String, nil ], default: nil
property :snippet_path, [ String, nil ], default: nil
property :snippet_file, [ String, nil ], default: nil
property :snippet_id, String, default: 'default'
#property :content, String, required: true
property :source_file, String, required: true

def initialize(*args)
  super
  @snippet_path = @snippet_path || current_snippet_path
  @snippet_file = @snippet_file || current_snippet_file
  @language = language_from_extension(::File.extname(file_name))
end

action :create do
  # Copy the file locally.
  directory ::File.dirname(file_name) do
    recursive true
  end
  # file ::File.expand_path(file_name) do
  #   content content
  # end
  cookbook_file ::File.expand_path(file_name) do
    source source_file
  end

  # This is the file that holds the manifest.
  manifest_filename = ::File.join(snippet_path, snippet_file) + '.yml'

  # Generate a base filename to store the file.
  base_code_filename = make_base_filename(snippet_file + snippet_id)

  # Ensure snippet directory exists.
  directory snippet_path do
    recursive true
  end

  # Update the manifest.
  new_item = {
    name: snippet_id,
    canonical_tag: "<% code_snippet(current_page, '#{snippet_file}', '#{snippet_id}') %>",
    language: language,
    path: file_name,
    codefile: code_file(base_code_filename, ::File.extname(file_name))
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

def language_from_extension(ext)
  case ext
  when '.rb'
    'ruby'
  else
    raise "Unknown file extenion '#{ext}'."
  end
end
