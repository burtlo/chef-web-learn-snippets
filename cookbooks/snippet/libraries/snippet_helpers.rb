module LearnChef
  module SnippetHelpers

  def current_snippet_path
    @@snippet_path
  end

  def current_snippet_file
    @@snippet_file
  end

  def current_cwd
    @@cwd
  end

  def with_snippet_path(snippet_path, &block)
    old_snippet_path = @@snippet_path
    @@snippet_path = File.join(node.default['snippets']['root_directory'], snippet_path)
    if block_given?
        begin
          yield
        ensure
          @@snippet_path = old_snippet_path
        end
      end
  end

  def with_snippet_file(snippet_file, &block)
    old_snippet_file = @@snippet_file
    @@snippet_file = snippet_file
    if block_given?
        begin
          yield
        ensure
          @@snippet_file = old_snippet_file
        end
      end
  end

  def with_cwd(cwd, &block)
    old_cwd = @@cwd
    @@cwd = cwd
    if block_given?
        begin
          yield
        ensure
          @@cwd = old_cwd
        end
      end
  end

  # Generates a unique but consistent base filename for stdout, stderr, and code files.
  def make_base_filename(s)
    require 'digest'
    Digest::SHA256.hexdigest(s)[0..7]
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
    manifest[:snippets].delete_if {|h| h[:name] == snippet_id } unless manifest[:snippets].empty?
    manifest[:snippets].push new_item
    manifest[:snippets].sort! { |x, y| y[:name] <=> x[:name] }
    manifest.to_yaml(line_width: -1)
  end

  private

  @@snippet_path = nil
  @@snippet_file = nil
  @@cwd = nil

end; end
