module Classifieds
  class Parser
    class << self
      include Utils

      def parse(text)
        lines = text.each_line.map(&:chomp)
        result = lines.each_with_object([]) do |line, array|
          target = detect_target(line)

          case target
          when Array
            if classifieds_ignore?(line)
              target.each do |file|
                array.delete(file)
              end
            else
              array.concat(target)
            end
          when String
            if classifieds_ignore?(line)
              array.delete(target)
            else
              array << target
            end
          end
        end

        result
      end

      def detect_target(string)
        path = string.match(/^!?(.+)/)[1]
        absolute_path = File.join(root_directory, path)

        # Dir.glob notation
        if absolute_path.include?('*')
          recursive_glob(absolute_path)
        else
          case File.ftype(absolute_path)
          when 'file'
            absolute_path
          when 'directory'
            recursive_glob(File.join(absolute_path, '*'))
          else
            raise ParseError, "invalid file type: #{string}"
          end
        end
      rescue Errno::ENOENT
      end

      def classifieds_ignore?(string)
        string.start_with?('!')
      end

      def recursive_glob(pattern)
        Dir.glob(pattern).each_with_object([]) do |absolute_path, array|
          case File.ftype(absolute_path)
          when 'file'
            array << absolute_path
          when 'directory'
            array.concat(recursive_glob(File.join(absolute_path, '*')))
          end
        end
      end
    end
  end
end
