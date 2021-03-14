source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.2" # '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.2.3"
# Use Puma as the app server
gem "puma", "~> 5.2.2"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6.0.0"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.2.1"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5.2.1"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.2.5'
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.16"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.7.2", require: false

# Framework building reusable, tetable and encapsulated ViewComponents in Rails
# docs: viewcomponent.org
gem "view_component", require: "view_component/engine"

group :development, :test do
  gem "rspec-rails", "~> 5.0.0"
  gem "shoulda-matchers", ">= 4.5.1"
  gem "capybara"

  gem "factory_bot_rails", "~> 6.1.0"
  gem "faker", "~> 2.17.0"

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.3.1"
  gem "listen", "~> 3.4.1"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  # powerful developer console.
  gem "pry", "~> 0.14.0"
  gem "pry-rails"
  gem "pry-stack_explorer", "~> 0.6.1"
  gem "pry-remote"
  gem "pry-byebug"
end

# Ruby code analyzer and formatter
group :rubocop, :development do
  gem "rubocop", ">= 1.11.0", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-packaging", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Pagination
gem "pagy", "~> 3.12.0"

# Alternative approach to web apps development.
# https://github.com/hotwired/hotwire-rails
gem "hotwire-rails"
