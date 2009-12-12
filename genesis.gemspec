# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{genesis}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["C. Jason Harrelson (midas)"]
  s.date = %q{2009-12-12}
  s.description = %q{A data seeding solution for Ruby on Rails providing seeding facilities far more advanced than the current built in Ruby on Rails solution.}
  s.email = %q{jason@lookforwardenterprises.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "genesis.gemspec",
     "lib/genesis.rb",
     "lib/genesis/active_record_extensions.rb",
     "lib/genesis/create_schema_seeds.rb",
     "lib/genesis/schema_seed.rb",
     "lib/genesis/seeder.rb",
     "rails_generators/genesis/USAGE",
     "rails_generators/genesis/genesis_generator.rb",
     "rails_generators/genesis/templates/genesis_override.rake",
     "rails_generators/genesis/templates/migration.rb",
     "rails_generators/prepare_seeding/USAGE",
     "rails_generators/prepare_seeding/prepare_seeding_generator.rb",
     "rails_generators/prepare_seeding/templates/genesis.rake",
     "rails_generators/prepare_seeding/templates/genesis_callbacks.rb",
     "spec/genesis_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/midas/genesis}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A data seeding solution for Ruby on Rails.}
  s.test_files = [
    "spec/genesis_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
