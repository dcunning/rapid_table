# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in rapid_table.gemspec
gemspec

gem "irb"
gem "rake", "~> 13.0"

group :development, :test do
  gem "capybara", "~> 3", require: false
  gem "cuprite", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "ferrum", "~> 0", require: false
  gem "importmap-rails"
  gem "propshaft"
  gem "puma"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", "~> 1.21"
  gem "rubocop-capybara"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "rubocop-rspec_rails"
  gem "simplecov", "~> 0.22.0", require: false
  gem "sqlite3"
  gem "stimulus-rails"
  gem "turbo-rails"
  gem "tzinfo-data", platforms: %i[windows jruby]
end
