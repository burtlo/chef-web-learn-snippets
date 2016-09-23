class String
  # Taken from activesupport.
  def strip_heredoc
    gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, ''.freeze)
  end

  def lines
    split('\n')
  end

  # Adapted from https://github.com/mynyml/unindent/blob/master/lib/unindent.rb
  def unindent
    indent = self.split("\n").select {|line| !line.strip.empty? }.map {|line| line.index(/[^\s]/) }.compact.min || 0
    self.gsub(/^[[:blank:]]{#{indent}}/, '')
  end
  def unindent!
    self.replace(self.unindent)
  end
end
