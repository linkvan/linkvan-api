source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 7.1.0"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6.2"
# Use Puma as the app server
gem "puma", "~> 6.4.2"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.4.1"
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.16"

# Use Active Storage variant
# gem "image_processing", "~> 1.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.3", require: false

# Framework building reusable, tetable and encapsulated ViewComponents in Rails
# docs: viewcomponent.org
gem "view_component"

# Use SCSS for stylesheets
#gem "sass-rails", "~> 6.0.0"
# As of Rails 7.0, sprockets is optional
# Removed sprockets-rails - using import maps instead
# gem "sprockets-rails"
# gem "dartsass-sprockets"

# Use Propshaft for asset pipeline
gem "propshaft"

# Use dartsass-rails for standalone Sass processing
gem "dartsass-rails"

# Authentication
gem "devise", "~> 4.9.3"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  gem 'dotenv-rails'

  gem "rspec-rails", "~> 7.1.1"
  gem "shoulda-matchers", ">= 6.2.0"
  gem "capybara"

  gem "factory_bot_rails", "~> 6.4.3"
  
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :windows]
end

# Faker gem - available in development/test, and in production when ALLOW_FAKE_DATA is set
gem "faker", "~> 3.4.2", groups: [:development, :test].tap { |groups| 
  groups << :production if ENV['ALLOW_FAKE_DATA'] == 'true' 
}

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", "~> 4.2.1"
  gem "listen", "~> 3.9.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem "spring"

  # powerful developer console.
  gem "pry", "~> 0.14.2"
  gem "pry-rails"
  gem "pry-stack_explorer", "~> 0.6.1"
  gem "pry-remote"
  gem "pry-byebug"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 3.3.1"
  gem "memory_profiler"
  gem "stackprof"

  # Replaces standard Rails' error page with a more useful error page
  gem 'better_errors'
end

# Ruby code analyzer and formatter
group :rubocop, :development do
  gem "rubocop", ">= 1.81.1", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-packaging", require: false

  # security checks
  gem "brakeman"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mri, :windows]

# Pagination
gem "pagy", "~> 9.4.0"

# Alternative approach to web apps development.
# https://github.com/hotwired/hotwire-rails
gem "hotwire-rails"
gem "turbo-rails"
gem "requestjs-rails"

# Colorize terminal output
gem "colorize"

# Adds support to inline SVG images
gem "inline_svg"

gem "haversine", git: "https://github.com/fabionl/haversine.git"
gem "geo_coord", require: "geo/coord"
gem 'geocoder', '~> 1.8'

# Adds JSON Web token control
gem "jwt"

# Import maps for ESM-based JavaScript handling
gem "importmap-rails"

# Aborts requests that are taking too long.
#   Set the timeout by setting the RACK_TIMEOUT_SERVICE_TIMEOUT env var
# gem "rack-timeout"

# Http client for making API requests
gem "faraday", "~> 2.14.0"

# OpenStruct for easy data modeling - removed from standard library since ruby 3.5
gem "ostruct"
