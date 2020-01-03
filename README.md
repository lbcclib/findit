# Find It

[![Build Status](https://travis-ci.org/lbcclib/findit.svg?branch=master)](https://travis-ci.org/lbcclib/findit)
[![Coverage Status](https://coveralls.io/repos/github/lbcclib/findit/badge.svg?branch=master)](https://coveralls.io/github/lbcclib/findit?branch=master)

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), Postgres, and various other projects.

## Installing Find It

Here's how to get this running for yourself:

1. Make sure that Ruby, Rails, Git, and Java are installed on your computer.
  * For folks running Linux, the OpenJDK version of Java should be sufficient; I haven't needed to use Oracle Java for this setup.
  * For folks running Windows, install [JRuby](http://jruby.org/), then run the command `gem install rails -v 4.2.7`. Also download and install [Git](https://git-scm.com/download/win)
2. Clone this repository.
3. Add the appropriate info to .env
4. `rake db:migrate`
5. You may also need to add the following three lines to app/config/initializers/assets.rb:
```
Rails.application.config.assets.precompile += %w( icons/* )
Rails.application.config.assets.precompile += %w( blacklight/findit.png )
Rails.application.config.assets.precompile += %w( *.png )
```
6. Get solr running with `cd solr && ./set_up_solr.sh`
7. `rails s`

## Contributing to this software

1. Sign in to GitHub.
2. Click "Fork" to make your own working copy of the repo.
3. Follow the installation instructions.
4. Make your changes.
5. Submit a pull request to get your changes incorporated. This sounds complicated, but it's actually pretty simple:
  * Go to your forked repository.
  * Click the pull requests tab
  * Click New Pull Request.
  * Verify your changes, then click "Create pull request".

## Working with EDS

First, add a .env.local file with the correct credentials.

Then you can open the rails console -- `rails c` -- where you can type:

```
mySession = EBSCO::EDS::Session.new
mySession.session_token
article = {:dbid => 'a9h', :an => '138929081'}
mySession.retrieve article
myDuplicateSession = EBSCO::EDS::Session.new session_token: mySession.session_token
```
