source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.3.3'
# Use postgresql as the database for Active Record
if RUBY_PLATFORM =~ (/jruby/) || RUBY_PLATFORM =~ (/java/)
  # THe custom git repository will not be needed as soon as they release version 60.0 to rubygems.org
  gem 'activerecord-jdbc-adapter', git: 'https://github.com/sandbergja/activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter', git: 'https://github.com/sandbergja/activerecord-jdbc-adapter'
else
  gem 'pg', '>= 0.18', '< 2.0'
end
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development do
  gem 'brakeman'
  gem 'rack-mini-profiler'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-solr'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'blacklight', '~>7.12.0'

gem 'activerecord-session_store'
gem 'blacklight-citeproc', '>=0.0.4'
gem 'blacklight-locale_picker'
gem 'blacklight_range_limit'
gem 'bootstrap', '4.1.3'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails'
gem 'ebsco-eds', github: 'sandbergja/edsapi-ruby'
gem 'evergreen_holdings', '>=0.3.0'
gem 'exception_notification'
gem 'jquery-rails'
gem 'material_design_icons'
gem 'rails-i18n'
gem 'rsolr', '>= 1.0', '< 3'
gem 'solr_wrapper'
gem 'traject'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'warbler', '>=1.4.0'

# 4.1.x is currently the latest version of http that we can use,
# since later versions depend on http-client, which is incompatible
# with warbler, see https://github.com/jruby/warbler/issues/482
gem 'http', '~>4.1.1'

gem 'material_icons'
gem 'openlibrary-covers', github: 'sandbergja/openlibrary-covers', branch: 'main'
gem 'view_component', require: 'view_component/engine'
