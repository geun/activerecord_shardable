# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord_shardable/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-shardable"
  spec.version       = ActiverecordShardable::VERSION
  spec.authors       = ["geun"]
  spec.email         = ["geun@touchingsignal.com"]
  spec.description   = %q{Migration heler to make shardable table for active record }
  spec.summary       = %q{Migration heler to make shardable table}
  spec.homepage      = "https://github.com/geun/activerecord_shardable"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
