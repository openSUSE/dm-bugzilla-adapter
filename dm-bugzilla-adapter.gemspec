# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dm-bugzilla-adapter/version"

Gem::Specification.new do |s|
  s.name        = "dm-bugzilla-adapter"
  s.version     = BugzillaAdapter::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = "https://github.com/openSUSE/dm-bugzilla-adapter"
  s.summary     = %q{A datamapper adapter for Bugzilla (aka bugzilla.novell.com)}
  s.description = %q{Use it in Ruby applications to access Bugzilla}

  s.add_dependency("dm-core", ["~> 1.2.0"])
  s.add_dependency("bicho", ["~> 0.0.5"])
  s.add_dependency("nokogiri", ["~> 1.4"])
  
  s.rubyforge_project = "dm-bugzilla-adapter"

  s.files         = `git ls-files`.split("\n")
  s.files.reject! { |fn| fn == '.gitignore' }
  s.extra_rdoc_files    = Dir['README*', 'TODO*', 'CHANGELOG*']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
