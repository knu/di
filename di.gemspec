# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'di'

Gem::Specification.new do |gem|
  gem.name          = "di"
  gem.version       = MYVERSION
  gem.authors       = ["Akinori MUSHA"]
  gem.email         = ["knu@idaemons.org"]
  gem.description   = <<EOS
The di(1) command wraps around GNU diff(1) to provide reasonable
default settings and some original features.
EOS
  gem.summary       = %q{A wrapper around GNU diff(1)}
  gem.homepage      = "https://github.com/knu/di"
  gem.license       = "2-clause BSDL"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  gem.add_runtime_dependency("diff-lcs", ["~> 1.2.2"])
end
