# coding: utf-8
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

Gem::Specification.new do |s|
  s.name = %q{trak-ruby}
  s.version = '0.0.2'
  s.authors = ["Brian Sewell"]
  s.email = ["bwsewell@gmail.com"]
  s.description = %q{trak.io helps you track the metrics that actually matter to your startup}
  s.summary = %q{Ruby bindings for the trak.io API}
  s.homepage = %q{http://docs.trak.io/}
  s.license = "MIT"
  s.default_executable = %q{trak}

  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
end
