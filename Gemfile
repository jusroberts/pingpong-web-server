source 'https://rubygems.org'

gem 'rails', '4.1.14.1'
gem 'sass-rails', '~> 5.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'hamlit-rails' #faster haml, uses slightly different syntax
gem 'foundation-rails'
gem 'websocket-rails'
gem 'faye-websocket', '0.10.0'
gem 'cloudinary'
gem "rails-erd"

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-minitest'
  gem 'dotenv-rails'
end

group :test do
  gem "minitest-reporters"
  gem "connection_pool"
  gem "rake"
end

group :test, :development do
  gem 'pry-byebug'
  gem 'sqlite3'
end

group :production do
  gem 'rails_12factor'
  gem 'pg'
  gem 'newrelic_rpm'
end
