# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '~> 5.0.0', '< 5.1'

gem 'mongoid', '~> 6.0.1'
gem 'bson_ext'

gem 'oj'
gem 'oj_mimic_json'
gem 'active_model_serializers', '~> 0.10.2'
gem 'curb', require: false
gem 'active_hash'
gem 'will_paginate_mongoid'

group :development, :test do
  gem 'rspec-rails', '~> 3.5.1'
  gem 'byebug'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rspec-activejob'
  gem 'dotenv-rails'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry-rails'
  gem 'brakeman', require: false
  gem 'annotate'
end

group :test do
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
end

# Server
gem 'puma'
gem 'redis', '~> 3.2'
gem 'redis-namespace'
gem 'rack-cors'
gem 'rack-attack'
gem 'sidekiq'
gem 'newrelic_rpm'
gem 'tzinfo-data'
gem 'httparty'
