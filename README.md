# Find It

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), with a few other gems thrown in.  This repository represents the changes we made from a basic installation of blacklight.

In theory, you should be able to get this to work on Windows and Linux boxes using [Ruby or JRuby](https://github.com/sandbergja/discovery_layer/issues/60), but has only been tested in the following environments:

* JRuby on Windows Server 2013
* Ruby on Ubuntu 15.10

## Installing Find It

Here's how to get this running for yourself:

1. Follow the Blacklight [Quickstart install instructions](https://github.com/projectblacklight/blacklight/wiki/Quickstart).  Use the "hard way", rather than the one-liner to get your app started.  Make sure to include Devise in this installation process.  Also be sure to use a version of Blacklight in the 5.x.x series; Find It isn't set up to use Blacklight 6 yet.
2. `cd` into the directory that you created.
4. `git init`
5. `git remote add findit git@github.com: Username/Repository`.
6. `git pull findit master`
7. `git reset --hard findit/master`
8. Add `gem 'jettywrapper'` to the Gemfile.
8. `bundle install` to make sure you have all the correct gems installed.  You may have to do a few `bundle update` commands.
10. `rails generate ahoy:stores:active_record`
11. `rake db:migrate`
12. Open up config/secrets.yml, and add your article_api_username and article_api_password.
13. You may also need to add the following three lines to app/config/initializers/assets.rb:
```
Rails.application.config.assets.precompile += %w( icons/* )
Rails.application.config.assets.precompile += %w( blacklight/findit.png )
Rails.application.config.assets.precompile += %w( *.png )
```

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
