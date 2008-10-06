require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new { |spec|
  spec.name = "di"
  spec.version = "0.1.1"
  spec.summary = "A wrapper around GNU diff(1)"
  spec.author = "Akinori MUSHA"
  spec.email = "knu@idaemons.org"
  spec.homepage = "http://www.idaemons.org/projects/di/"
  spec.rubyforge_project = "unixutils"
  spec.description = <<EOS
The di(1) command wraps around GNU diff(1) to provide reasonable
default settings and some original features.
EOS
  spec.executables = ["di"]
  spec.files = spec.executables.map { |x| File.join("bin", x) } + %w[README.txt History.txt]
}

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end
