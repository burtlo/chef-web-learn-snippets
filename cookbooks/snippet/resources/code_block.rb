include LearnChef::SnippetHelpers
include Chef::Mixin::ShellOut

# Uniquely identifies the code file.
property :id, String, required: true, name_property: true
property :tutorial, [ String, nil ], default: nil
property :platform, [ String, nil ], default: nil
property :virtualization, [ String, nil ], default: nil
property :lesson, [ String, nil ], default: nil
property :step, [ String, nil ], default: nil
# The destination file path for replaying the sceanrio.
property :file_path, String, required: true
# The source cookbook filename.
property :source_filename, String, required: true
property :language, [ String, nil ], default: nil

def initialize(*args)
  super
  @tutorial ||= snippet_options[:tutorial]
  @platform ||= snippet_options[:platform]
  @virtualization ||= snippet_options[:virtualization]
  @lesson ||= snippet_options[:lesson]
  @step ||= snippet_options[:step]
end

action :create do
  # Where we place files for playing the scenario.
  scenario_full_path = ::File.expand_path(file_path)
  scenario_directory_name = ::File.dirname(scenario_full_path)

  # Where we place snippet files.
  snippet_partial_path = ::File.join(tutorial, platform, virtualization, lesson, step, id)
  snippet_full_path = ::File.join(snippets_root_dir, snippet_partial_path)
  snippet_metadata_filename = ::File.join(snippet_full_path, 'metadata.yml')
  snippet_code_partial_path = ::File.join(snippet_partial_path, ::File.basename(file_path))
  snippet_code_fullpath = ::File.join(snippet_full_path, ::File.basename(file_path))

  # Metadata about the snippet.
  metadata = {
    snippet_tag: "<% code_snippet(page: current_page, path: '#{::File.join(step, id)}') %>",
    language: language || language_from_file_path,
    display_path: file_path,
    file: ::File.basename(snippet_code_fullpath)
  }

  # Copy the file locally.
  directory scenario_directory_name do
    recursive true
  end
  cookbook_file scenario_full_path do
    source source_filename
  end

  # Write metadata.
  directory ::File.dirname(snippet_metadata_filename) do
    recursive true
  end
  file snippet_metadata_filename do
    content metadata.to_yaml(line_width: -1)
  end

  # Write codefile snippet.
  cookbook_file snippet_code_fullpath do
    source source_filename
  end
end

def language_from_file_path
  language = map_language(file_path)

  if language.nil?
    # Perhaps no extension. Special case based on filename.
    # TODO
    raise "Unknown language for '#{file_path}'."
  end

  language
end

def map_language(file_path)
  file_ext = ::File.extname(file_path)
  case file_ext
  when '.rb'
    'ruby'
  when '.htm', '.html'
    'html'
  when '.erb'
    # Strip .erb extension and get language for base name.
    file_path2 = ::File.basename(file_path, file_ext)
    map_language(file_path2)
  else
    nil
  end
end
