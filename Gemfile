source 'https://rubygems.org'

gem 'rails', '~> 7.1'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'

# QR Code
gem 'rqrcode', '~> 2.2'

# Image processing
gem 'mini_magick', '~> 4.12'
gem 'image_processing', '~> 1.12'

# Auth
gem 'jwt', '~> 2.7'
gem 'bcrypt', '~> 3.1'

# Storage (optional - for saving QR images)
gem 'aws-sdk-s3', '~> 1.136', require: false

# API
gem 'rack-cors'
gem 'active_model_serializers', '~> 0.10'

# Utils
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
end

group :development do
  gem 'rubocop-rails', require: false
end