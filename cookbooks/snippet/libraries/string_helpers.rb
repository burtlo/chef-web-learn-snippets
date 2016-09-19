class String
  # Taken from activesupport.
  def strip_heredoc
    gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, ''.freeze)
  end

  def lines
    split("\n")
  end
end
