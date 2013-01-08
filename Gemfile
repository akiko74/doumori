source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'mysql2'
gem 'paperclip', '~> 3.0'

gem 'chunky_png'
gem 'qrio', :git => 'git://github.com/rubysolo/qrio.git'

gem 'aws-s3'
gem 'aws-sdk'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'jquery-rails'
  gem 'therubyracer'
  gem 'less-rails'
end

group :development do
  gem 'meta_request'
end

group :test, :development do
  gem 'debugger'
  gem 'capistrano', :require => false
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

group :production do
  gem 'passenger'
  gem 'heroku'
  gem 'pg'
end
