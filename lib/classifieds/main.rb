require 'digest/sha1'
require 'openssl'
require 'fileutils'

require 'safe_colorize'

require 'thor'

module Classifieds
  class Main < Thor
    using SafeColorize

    def initialize(*args)
      @prefix = Digest::SHA1.hexdigest('classifieds')
      super
    end

    desc 'init', 'Initialize classifieds'
    def init
      if File.exists?(SOURCE_FILE)
        puts 'Classifieds already initialized'.color(:red)
      else
        FileUtils.touch(SOURCE_FILE)
        puts "#{SOURCE_FILE} was created".color(:green)
      end
    end

    desc 'encrypt', 'Encrypt files which were described in .classifieds'
    def encrypt
      @password = ask_password
      retype_password

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
    def decrypt
      @password = ask_password

      decrypted_files = classifieds.each_with_object([]) do |file_path, array|
        next if decrypted?(file_path)

        file = File.open(file_path, 'r+')
        file.flock(File::LOCK_EX)

        file.read(@prefix.size)
        data = file.read.chomp

        begin
          decrypted = decrypt_data(data)
        rescue OpenSSL::Cipher::CipherError
          STDERR.puts 'The entered password is wrong: '.color(:red) + file_path
          next
        end

        file.rewind
        file.write decrypted
        file.truncate(file.tell)

        array << file_path
      end

      puts 'Decrypted:'.color(:green) unless decrypted_files.empty?
      decrypted_files.each {|decrypted_file| puts "\t" + decrypted_file }
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

    def classifieds
      File.open(SOURCE_FILE) do |f|
        Parser.parse(f.read)
      end
    rescue Errno::ENOENT
      STDERR.puts "#{SOURCE_FILE} is not found".color(:red)
      exit 1
    end

    def encrypt_data(data)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.encrypt
      cipher.pkcs5_keyivgen(@password)
      cipher.update(data) + cipher.final
    end

    def decrypt_data(data)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.pkcs5_keyivgen(@password)
      cipher.update(data) + cipher.final
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
