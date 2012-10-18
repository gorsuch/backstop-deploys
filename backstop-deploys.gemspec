# -*- encoding: utf-8 -*-
require File.expand_path('../lib/backstop-deploys/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Gorsuch"]
  gem.email         = ["michael.gorsuch@gmail.com"]
  gem.description   = %q{An extension to backstop to allow submission to Librato Metrics}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/gorsuch/backstop-deploys'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'backstop-deploys'
  gem.require_paths = ['lib']
  gem.version       = Backstop::Deploys::VERSION
  gem.add_development_dependency('rack-test')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('webmock')
  gem.add_dependency('rest-client')
  gem.add_dependency('sinatra')
end
