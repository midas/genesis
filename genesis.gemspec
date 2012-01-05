# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "genesis/version"

Gem::Specification.new do |s|
  s.name        = "genesis"
  s.version     = Genesis::VERSION
  s.authors     = ["C. Jason Harrelson"]
  s.email       = ["jason@lookforwardenterprises.com"]
  s.homepage    = "https://github.com/midas/genesis"
  s.date        = %q{2010-09-19}
  s.summary     = %q{A data seeding solution for Ruby on Rails.}
  s.description = %q{A data seeding solution for Ruby on Rails providing seeding facilities far more advanced than the current built in Ruby on Rails solution.}

  s.rubyforge_project = "genesis"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w(
    gem-dandy
    rspec
    ruby-debug
    guard
    rb-fsevent
    growl
    guard-rspec
    rails
    genspec
  ).each do |development_dependency|
    s.add_development_dependency development_dependency
  end

  # s.add_runtime_dependency "rest-client"
end
