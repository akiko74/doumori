source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'mysql2'
gem 'paperclip', '~> 3.0'

gem 'chunky_png'

gem 'aws-s3'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'jquery-rails'
  gem 'therubyracer'
  gem 'less-rails'
end

group :test, :development do
  gem 'debugger'
  gem 'capistrano', :require => false
end

group :production do
  gem 'passenger'
  gem 'heroku'
  gem 'pg'
end
