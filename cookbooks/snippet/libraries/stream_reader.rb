# Adapted from https://gist.github.com/kwilczynski/bc1c19bd89b712ce3f35
class Chef
  class Recipe
    class StreamReader
      require 'stringio'

      def initialize(&block)
        @block = block
        @buffer = StringIO.new
        @buffer.sync = true if @buffer.respond_to?(:sync)
      end

      def <<(chunk)
        overflow = ''

        @buffer.write(chunk)
        @buffer.rewind

        @buffer.each_line do |line|
          if line.match(/\r?\n/)
            @block.call(line.strip)
          else
            overflow = line
          end
        end

        @buffer.truncate(@buffer.rewind)
        @buffer.write(overflow)
      end
    end
  end
end
