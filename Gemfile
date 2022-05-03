source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

gem 'aws-sdk-ses', '~> 1.47.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'daemons'
gem 'delayed_job_active_record', '~> 4.1.7'
gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '~> 0.8.0'
gem 'json-schema', '>= 2.8.1'
gem 'jwe', '~> 0.4.0'
gem 'jwt'
gem 'metrics_adapter', '0.2.0'
gem 'mime-types'
gem 'mixpanel-ruby'
gem 'notifications-ruby-client'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6'
gem 'rails', '~> 6.1.5.1', '< 7.0.0.0'
gem 'sentry-delayed_job', '~> 5.2.1'
gem 'sentry-rails', '~> 5.2.1'
gem 'sentry-ruby', '~> 5.2.1'
gem 'typhoeus'
gem 'tzinfo-data'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '>= 3.8.0'
  gem 'rubocop', '~> 0.87.1'
  gem 'rubocop-govuk'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'guard-shell'
  gem 'listen'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'simplecov'
  gem 'simplecov-console', require: false
  gem 'timecop'
  gem 'webmock'
end
