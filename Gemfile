source "https://rubygems.org"

ruby File.read("./.ruby-version").chomp

gem "rails", "4.1.9"

gem "sqlite3", group: [:development, :test]
gem "pg", group: :production
gem "rails_12factor", group: :production

# Use SCSS for stylesheets
gem "sass-rails", "~> 4.0.3"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .js.coffee assets and views
gem "coffee-rails", "~> 4.0.0"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.0"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 0.4.0", group: :doc

# Spring speeds up development by keeping your application
# running in the background.
# Read more: https://github.com/rails/spring
gem "spring", group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "pry", group: [:development, :test]

gem "haml-rails"
gem "kramdown"

gem "omniauth"
gem "omniauth-instapaper"
gem "instapaper_full", github: "mattb/instapaper_full"
gem "film_snob", github: "maxjacobson/film_snob"
gem "unicorn"
gem "bootstrap-sass-rails"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "rspec-rails"
  gem "capybara"
end

gem "byebug"
gem "rubocop", "0.37", require: false

gem "codeclimate-test-reporter", group: :test, require: nil

gem "launchy"
