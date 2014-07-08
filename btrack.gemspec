# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'btrack/version'

Gem::Specification.new do |spec|
  spec.name          = "btrack"
  spec.version       = Btrack::VERSION
  spec.authors       = ["Chen Fisher"]
  spec.email         = ["chen.fisher@gmail.com"]
  spec.description   = %q{Enables tracking and querying of any activity in a website or process with minimum memory signature and maximum performance (thanks to redis)}
  spec.summary       = %q{Activity tracker with minimum memory signature and maximum performance (thanks to redis)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "redis"
  spec.add_dependency "hook_me_up"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "wrong"
end
