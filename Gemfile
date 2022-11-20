source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0.4"
gem "mysql2", "~> 0.5"
gem "puma", "~> 5.0"
gem "redis", "~> 4.0"
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails'
  gem 'rack-proxy', '~> 0.7.2'
end

group :development do
  gem "web-console"
end
