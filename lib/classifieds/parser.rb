module Classifieds
  class Parser
    def self.parse(text)
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

    def self.detect_target(string)
      path = string.match(/^!?(.+)/)[1]
      absolute_path = File.join(Dir.pwd, path)

      # Dir.glob notation
      if absolute_path.include?('*')
        recursive_glob(absolute_path)
      else
        case File.ftype(path)
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

    def self.classifieds_ignore?(string)
      string.start_with?('!')
    end

    def self.recursive_glob(pattern)
      Dir.glob(pattern).each_with_object([]) do |path, array|
        case File.ftype(path)
        when 'file'
          array << path
        when 'directory'
          array.concat(recursive_glob(File.join(path, '*')))
        end
      end
    end
  end
end
