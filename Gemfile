# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use postgresql as the database for Active Record
platforms :jruby do
  gem 'activerecord-jdbc-adapter', '~> 60.2'
  gem 'activerecord-jdbcpostgresql-adapter'
end

group :production, :development, :test do
  # Use Puma as the app server
  gem 'puma'
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 5.1.0'
  # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
  gem 'webpacker', '~> 4.0'
  # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
  gem 'turbolinks', '~> 5'
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem 'jbuilder'

  gem 'activerecord-session_store'
  gem 'blacklight-locale_picker'
  gem 'bootstrap', '4.1.3'
  gem 'devise-guests'
  gem 'ebsco-eds', github: 'sandbergja/edsapi-ruby'
  gem 'evergreen_holdings', '>=0.3.0'
  gem 'exception_notification'
  gem 'jquery-rails'
  gem 'material_design_icons'
  gem 'material_icons'
  gem 'rails-i18n'
  gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
  gem 'view_component', require: 'view_component/engine'
  gem 'warbler', '>=1.4.0'
end

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

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

gem 'blacklight', '~>7.14'

gem 'dotenv-rails'
gem 'rsolr', '>= 1.0', '< 3'
gem 'solr_wrapper'
gem 'traject'

# 4.1.x is currently the latest version of http that we can use,
# since later versions depend on http-client, which is incompatible
# with warbler, see https://github.com/jruby/warbler/issues/482
gem 'blacklight-citeproc', '>=0.0.4'
gem 'blacklight_range_limit'
gem 'devise'
gem 'http', '~>4.1.1'

gem 'library_stdnums'
gem 'openlibrary-covers', github: 'sandbergja/openlibrary-covers', branch: 'main'
gem 'rack-cors'

group :indexer do
  gem 'activerecord-nulldb-adapter'
end
