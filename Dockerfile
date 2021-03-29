FROM jruby:9.2.16.0-jdk

# Necessary for bundler to properly install some gems
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update;apt-get install -y git make nodejs
RUN gem install bundler

RUN mkdir -p /var/www/findit
WORKDIR /var/www/findit
COPY Gemfile* /var/www/findit/
RUN bundle install --jobs=4

COPY . /var/www/findit
COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
