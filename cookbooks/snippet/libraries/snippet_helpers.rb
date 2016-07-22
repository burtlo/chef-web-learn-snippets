module LearnChef
  module SnippetHelpers

  def snippet_options
    @@options
  end

  def with_snippet_options(options, &block)
    old_options = {}
    options.each do |k,v|
      old_options[k] = @@options[k]
      @@options[k] = v
    end
    if block_given?
      begin
        yield
      ensure
        old_options.each do |k,v|
          @@options[k] = v
        end
      end
    end
  end

  def snippets_root
    node.default['snippets']['root_directory']
  end

  # Generates a unique but consistent base filename for stdout, stderr, and code files.
  def make_base_filename(s)
    require 'digest'
    Digest::SHA256.hexdigest(s)[0..7]
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

  # Loads the manifest file, or generates the content for a new manifest if the file does not exist.
  def load_manifest(filename)
    require 'yaml'
    if ::File.exist?(filename)
      YAML.load_file(filename)
    else
      { snippets: [] }
    end
  end

  # Inserts the new item into the manifest.
  def update_manifest(manifest, new_item)
    manifest[:snippets].delete_if {|h| h[:id] == id } unless manifest[:snippets].empty?
    manifest[:snippets].push new_item
    manifest[:snippets].sort! { |x, y| y[:id] <=> x[:id] }
    manifest.to_yaml(line_width: -1)
  end

  private

  @@options = {}

end; end
