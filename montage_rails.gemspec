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

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "https://1jB4bNjnEKjP4xyR8NNr@gem.fury.io/app35692279_heroku_com/"
  end

  s.add_dependency "rails", "~> 4.0", ">= 4.0"
  s.add_dependency "ruby-montage", "~> 0.1", ">= 0.1.7"
  s.add_dependency "json", "~> 1.8"
  s.add_dependency "virtus", "~> 0.0", ">= 1.0"

  s.add_development_dependency "sqlite3", "~> 0.0"
  s.add_development_dependency "bundler", "~> 1.9"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.5", ">= 5.5.0"
  s.add_development_dependency "shoulda-context", "~> 1.0"
  s.add_development_dependency "mocha", "~> 1.1"
  s.add_development_dependency "simplecov", "~> 0.9.1"
  s.add_development_dependency "coveralls", "~> 0.0"
  s.add_development_dependency "vcr", "~> 0.0"
  s.add_development_dependency "webmock", "~> 0.0"
  s.add_development_dependency "pry-rails", "~> 0.0"
  s.add_development_dependency "minitest-reporters", "~> 0.0"
  s.add_development_dependency "will_paginate", "~> 3.0", ">= 3.0"
end
