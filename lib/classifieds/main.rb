require 'digest/sha1'
require 'fileutils'

require 'safe_colorize'

require 'thor'

module Classifieds
  class Main < Thor
    include Utils
    using SafeColorize

    def initialize(*args)
      unless classifieds_repository?
        STDERR.puts "#{SOURCE_FILE} is not found in this repository".color(:red)
        exit 1
      end

      source_directory = File.join(root_directory, SOURCE_DIRECTORY)
      FileUtils.mkdir_p(source_directory) unless Dir.exists?(source_directory)
      @prefix = Digest::SHA1.hexdigest('classifieds')
      super
    end

    desc 'keygen', 'Generate identity files using by public key encryption'
    option :force, type: :boolean, aliases: '-f'
    def keygen
      if !options[:force] && keygenerated?
        STDERR.puts 'Already generated in this repository'.color(:red)
        exit 1
      else
        OpenSSL::Random.seed(File.read('/dev/random', 16))
        rsa = OpenSSL::PKey::RSA.new(2048)
        pub = rsa.public_key
        File.open(File.join(root_directory, PUBLIC_KEY_PATH), 'w') do |f|
          f.puts pub.to_pem
        end
        File.open(File.join(root_directory, COMMON_KEY_PATH), 'w') do |f|
          f.puts pub.public_encrypt(OpenSSL::Random.random_bytes(16))
        end
        puts rsa
      end
    end

    desc 'encrypt', 'Encrypt files which were described in .classifieds'
    option :identity_file, type: 'string', aliases: '-i'
    def encrypt
      if identity_file = options[:identity_file]
        rsa = OpenSSL::PKey::RSA.new(File.read(identity_file).chomp)
        @password = rsa.private_decrypt(File.read(File.join(root_directory, COMMON_KEY_PATH)).chomp)
      else
        @password = ask_password
        retype_password
      end

      encrypted_files = classifieds.each_with_object([]) do |file_path, array|
        next if encrypted?(file_path)

        file = File.open(file_path, 'r+')
        file.flock(File::LOCK_EX)
        data = file.read.chomp

        begin
          encrypted = encrypt_data(data)
        rescue ArgumentError
          next
        end

        file.rewind
        file.write @prefix + encrypted
        file.truncate(file.tell)

        array << file_path
      end

      puts 'Encrypted:'.color(:green) unless encrypted_files.empty?
      encrypted_files.each {|encrypted_file| puts "\t" + encrypted_file }
    end

    desc 'decrypt', 'Decrypt files which were described in .classifieds'
    option :identity_file, type: 'string', aliases: '-i'
    def decrypt
      if identity_file = options[:identity_file]
        rsa = OpenSSL::PKey::RSA.new(File.read(identity_file).chomp)
        @password = rsa.private_decrypt(File.read(File.join(root_directory, COMMON_KEY_PATH)).chomp)
      else
        @password = ask_password
      end

      failed_files = []
      decrypted_files = classifieds.each_with_object([]) do |file_path, array|
        next if decrypted?(file_path)

        file = File.open(file_path, 'r+')
        file.flock(File::LOCK_EX)
        file.read(@prefix.size)
        data = file.read.chomp

        begin
          decrypted = decrypt_data(data)
        rescue OpenSSL::Cipher::CipherError
          failed_files << file_path
          next
        end

        file.rewind
        file.write decrypted
        file.truncate(file.tell)

        array << file_path
      end

      puts 'Decrypted:'.color(:green) unless decrypted_files.empty?
      decrypted_files.each {|decrypted_file| puts "\t" + decrypted_file }
      puts 'Failed to decrypt:'.color(:red) unless failed_files.empty?
      failed_files.each {|failed_file| puts "\t" + failed_file }
    end

    desc 'status', 'Show a status of the encryption of this repository'
    def status
      encrypted_files = []
      unencrypted_files = []

      classifieds.each do |file|
        if encrypted?(file)
          encrypted_files << file
        else
          unencrypted_files << file
        end
      end
      puts 'Encrypted:'.color(:green) unless encrypted_files.empty?
      encrypted_files.each {|encrypted_file| puts "\t" + encrypted_file }
      puts 'Unencrypted:'.color(:red) unless unencrypted_files.empty?
      unencrypted_files.each {|unencrypted_file| puts "\t" + unencrypted_file }
    end

    private

    def ask_password
      print 'Password: '
      password = STDIN.noecho(&:gets)
      print "\n"

      password
    end

    def retype_password
      print 'Retype password: '
      password = STDIN.noecho(&:gets)
      print "\n"

      unless password == @password
        STDERR.puts 'Sorry, passwords do not match'.color(:red)
        @password = ask_password
        retype_password
      end
    end
  end
end
