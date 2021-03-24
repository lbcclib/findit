FROM jruby:9.2-jdk

# Necessary for bundler to properly install some gems
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV RAILS_ENV indexer
ENV BUNDLE_WITHOUT production:development:test

RUN mkdir -p /var/www/findit
COPY . /var/www/findit
RUN gem install bundler
WORKDIR /var/www/findit
RUN bundle install

# Main process is indexing and backing up the data
CMD ["bundle", "exec", "rake", "findit:data:fetch_and_index:all", "findit:data:export:as_solr"]
