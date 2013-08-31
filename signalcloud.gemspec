# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'signalcloud/version'

Gem::Specification.new do |gem|
  gem.name          = "signalcloud"
  gem.version       = SignalCloud::VERSION
  gem.authors       = ["Ian Lloyd"]
  gem.email         = ["ian@signalcloudapp.com"]
  gem.description   = %q{Access the SignalCloud API to manage tickets.}
  gem.summary       = %q{Tap into the SignalCloud API.}
  gem.homepage      = "http://www.signalcloudapp.com/api"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'api_smith', '~> 1.2.0'
  
  gem.add_development_dependency 'rspec'
end
