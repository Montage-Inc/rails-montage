$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "montage_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "montage_rails"
  s.version     = MontageRails::VERSION
  s.authors     = ["dphaener"]
  s.email       = ["dphaener@gmail.com"]
  s.homepage    = "https://github.com/EditLLC/rails-montage"
  s.summary     = "Rails integration for the Ruby Montage API wrapper"
  s.description = "Makes Rails play nice with Montage"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1", ">= 3.1.12"
  s.add_dependency "ruby-montage", "~> 0.4", ">= 0.4.2"
  s.add_dependency "json", "~> 1.8"
  s.add_dependency "virtus", "~> 1.0", ">= 1.0"

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "rails", "~> 4.2", ">= 4.2.1"
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "shoulda-context", "~> 1.0"
  s.add_development_dependency "mocha", "~> 1.1"
  s.add_development_dependency "simplecov", "~> 0.10"
  s.add_development_dependency "codecov", "~> 0.0"
  s.add_development_dependency "webmock", "~> 1.0"
  s.add_development_dependency "pry-rails", "~> 0.0"
  s.add_development_dependency "will_paginate", "~> 3.0", ">= 3.0"
  s.add_development_dependency "kaminari", "~> 0.16"
end
