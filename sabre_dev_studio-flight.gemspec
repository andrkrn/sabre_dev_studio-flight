# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sabre_dev_studio-flight/version'

Gem::Specification.new do |gem|
  gem.name          = "sabre_dev_studio-flight"
  gem.version       = SabreDevStudio::Flight::VERSION
  gem.authors       = ["Barrett Clark"]
  gem.email         = ["barrett.clark@sabre.com"]
  gem.description   = %q{Access the Sabre Travel Platform Services (TPS) Dev Studio Flight API}
  gem.summary       = %q{Access the Sabre Dev Studio API}
  gem.homepage      = "http://sabrelabs.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'geminabox'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'rdoc'
  gem.add_runtime_dependency 'sabre_dev_studio'
end
