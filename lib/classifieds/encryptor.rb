require 'openssl'
require 'base64'

module Classifieds
  class Encryptor
    def initialize(password, salt)
      @cipher = OpenSSL::Cipher.new('AES-256-CBC')
      @password = password
      @salt = salt
    end

    def encrypt(data)
      @cipher.encrypt
      key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
        @password,
        @salt,
        1000,
        @cipher.key_len + @cipher.iv_len
      )
      @cipher.key = key_iv[0, @cipher.key_len]
      @cipher.iv = key_iv[@cipher.key_len, @cipher.iv_len]
      Base64.encode64(@cipher.update(data) + @cipher.final)
    end

    def decrypt(data)
      @cipher.decrypt
      key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
        @password,
        @salt,
        1000,
        @cipher.key_len + @cipher.iv_len
      )
      @cipher.key = key_iv[0, @cipher.key_len]
      @cipher.iv = key_iv[@cipher.key_len, @cipher.iv_len]
      @cipher.update(Base64.decode64(data)) + @cipher.final
    end
  end
end
