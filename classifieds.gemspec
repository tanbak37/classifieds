lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'classifieds/version'

Gem::Specification.new do |spec|
  spec.name          = 'classifieds'
  spec.version       = Classifieds::VERSION
  spec.authors       = ["kaihar4"]
  spec.email         = ["0@kaihar4.com"]

  spec.summary       = 'File Encryption Manager'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/kaihar4/classifieds'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'safe_colorize'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
