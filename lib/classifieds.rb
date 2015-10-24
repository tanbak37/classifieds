require 'classifieds/exception'
require 'classifieds/parser'
require 'classifieds/main'

module Classifieds
  SOURCE_FILE = '.classifieds'
  SOURCE_DIRECTORY = '.classifieds.d'
  PUBLIC_KEY_PATH = File.join(SOURCE_DIRECTORY, 'public_key')
  COMMON_KEY_PATH = File.join(SOURCE_DIRECTORY, 'common_key')
end
