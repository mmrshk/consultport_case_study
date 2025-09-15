# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

gem "panko_serializer"

# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.1'

gem 'pry'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
gem "interactor", "~> 3.0"
gem 'httparty'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

gem 'rubocop'

gem 'money'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]
end

group :development do
  gem 'annotaterb'
end

group :test do
  gem 'rspec-rails'
  gem 'webmock'
end
