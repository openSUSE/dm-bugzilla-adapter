# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dm-bugzilla-adapter/version"

Gem::Specification.new do |s|
  s.name        = "dm-bugzilla-adapter"
  s.version     = DataMapper::Adapters::BugzillaAdapter::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = ""
  s.summary     = %q{A datamapper adapter for Bugzilla (aka bugzilla.novell.com)}
  s.description = %q{Use it in Ruby applications to access Bugzilla}

  s.add_dependency("bicho", ["~> 0.0.2"])
  s.add_dependency("nokogiri", ["~> 1.4"])
  
  s.rubyforge_project = "dm-bugzilla-adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
