# -*- encoding: utf-8 -*-
require File.expand_path('../lib/choose_your_own/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Burke"]
  gem.email         = ["spraints@gmail.com"]
  gem.description   = %q{Define multiple-choice inputs of in an ActionView form}
  gem.summary       = %q{Define multiple-choice inputs of in an ActionView form}
  gem.homepage      = "http://github.com/spraints/choose_your_own"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "choose_your_own"
  gem.require_paths = ["lib"]
  gem.version       = ChooseYourOwn::VERSION

  gem.add_dependency('activemodel',     '~> 3.0')
  gem.add_dependency('actionpack',      '~> 3.0')
end
