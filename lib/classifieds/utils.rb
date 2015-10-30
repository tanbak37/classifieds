require 'find'

module Classifieds
  module Utils
    def classifieds
      Parser.parse(File.read(File.join(root_directory, SOURCE_FILE)).chomp)
    end

    def classifieds_repository?
      !!root_directory
    end

    def keygenerated?
      File.exists?(File.join(root_directory, PUBLIC_KEY_PATH)) && File.exists?(File.join(root_directory, COMMON_KEY_PATH))
    end

    def root_directory
      @root_directory ||=
        begin
          target_directory = File.expand_path(Dir.pwd)
          until target_directory == '/' do
            Find.find(target_directory) do |path|
              return target_directory if path =~ %r|/#{Regexp.escape(SOURCE_FILE)}$|
              Find.prune if path =~ %r|^#{target_directory}/|
            end
            target_directory = File.expand_path('..', target_directory)
          end

          nil
        end
    end

    def encrypt_data(data)
      encryptor = Encryptor.new(@password, root_directory.split('/').pop)
      encryptor.encrypt(data)
    end

    def decrypt_data(data)
      encryptor = Encryptor.new(@password, root_directory.split('/').pop)
      encryptor.decrypt(data)
    end

    def encrypted?(file)
      File.open(file, 'r') do |f|
        !!f.read(@prefix.size).to_s.match(/\A#{@prefix}\z/)
      end
    end

    def decrypted?(file)
      !encrypted?(file)
    end
  end
end
