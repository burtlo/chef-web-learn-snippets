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

  def snippets_root_dir
    node.default['snippets']['root_directory']
  end

  private

  @@options = {}

end; end
