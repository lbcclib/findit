source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7.1'

group :production do
    if RUBY_PLATFORM=~ /jruby/ or RUBY_PLATFORM =~ /java/
        #gem 'pg', '0.17.1', :git => 'git://github.com/headius/jruby-pg.git', :branch => :master, :group => :production
	gem 'activerecord-jdbcpostgresql-adapter'
	gem 'jdbc-postgres', '~> 9.4.1200'
    else
        gem 'pg'
    end
end

group :development, :test do
    gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
    gem 'sqlite3', :platforms => :ruby
    gem 'activeuuid'
    gem 'jettywrapper'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.7.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Using RubyRhino under jruby, RubyRacer under ruby
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyrhino', :platforms => :jruby
gem 'therubyracer', :platforms => :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.2.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'activerecord-session_store'

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'faker'
  gem 'rake'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'warbler'

gem 'blacklight', '~> 6.6'

gem 'rsolr', '~> 1.1.2'
gem 'devise', '~> 4.2'
gem 'devise-guests', '~> 0.5'
gem 'blacklight-marc', '~> 6.1'

gem "blacklight_advanced_search", '~> 6.0.2'
gem "blacklight_range_limit", "~> 6.0"
gem "bibtex-ruby"
gem "citeproc-ruby"
gem "csl-styles"
gem "exception_notification"

gem 'ebsco-discovery-service-api'
gem 'evergreen_holdings', '~>0.1.3'
gem 'browser', '=1.1.0'

gem 'ahoy_matey'

gem 'coveralls', require: false
