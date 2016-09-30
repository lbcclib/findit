# Find It

[![Build Status](https://travis-ci.org/sandbergja/discovery_layer.svg?branch=master)](https://travis-ci.org/sandbergja/discovery_layer)
[![Coverage Status](https://coveralls.io/repos/github/sandbergja/discovery_layer/badge.svg?branch=master)](https://coveralls.io/github/sandbergja/discovery_layer?branch=master)

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), with a few other gems thrown in.  This repository represents the changes we made from a basic installation of blacklight.

In theory, you should be able to get this to work on Windows and Linux boxes using [Ruby or JRuby](https://github.com/sandbergja/discovery_layer/issues/60), but has only been tested in the following environments:

* JRuby on Windows Server 2013
* Ruby on Ubuntu 15.10 and 16.10

## Installing Find It

Here's how to get this running for yourself:

1. Make sure that Ruby, Rails, Git, and Java are installed on your computer.
  * For folks running Linux, the OpenJDK version of Java should be sufficient; I haven't needed to use Oracle Java for this setup.
  * For folks running Windows, you can install Ruby, Rails, and Git using the [Rails Installer](http://railsinstaller.org/en). I recommend that you use the 2.1 installer, due to a [bothersome issue with their 2.2 installer](https://github.com/railsinstaller/railsinstaller-windows/issues/81). 
2. Decide on a directory on your computer where you'd like to install Find It.  Open a console and navigate to that directory.
3. Type `rails _4.2.7_ new my_new_blacklight_app` to start a new Rails application, which will live in a subdirectory with the name you choose.  Replace `my_new_blacklightapp` with the name that you chose.

4. With the text editor of your choice, open the file called `Gemfile` in the new subdirectory. Add the line `gem 'blacklight', "~> 6.6"`
5. Run `bundle install`
6. Run `rails generate blacklight:install --devise --marc --jettywrapper`
7. Run `git init` so you can begin using git in this directory.
8. `git remote add findit [URL]` where URL is the clone URL for this repository.
9. `git pull findit master`
10. `git reset --hard findit/master`
11. `bundle install` again to make sure you have all the correct gems installed.  You may have to do a few `bundle update` commands.
13. `rake db:migrate`
14. Open up config/secrets.yml, and add your article_api_username and article_api_password.
15. You may also need to add the following three lines to app/config/initializers/assets.rb:
```
Rails.application.config.assets.precompile += %w( icons/* )
Rails.application.config.assets.precompile += %w( blacklight/findit.png )
Rails.application.config.assets.precompile += %w( *.png )
```

## Adventurous Installation

If you are feeling lucky, you can try the following, much shorter installation process.
It exists primarily to get a quick testing environment put together for CI purposes, but theoretically should also get a basic development install put together for you.

```
git clone https://github.com/sandbergja/discovery_layer
cd discovery_layer
rails _4.2.5_ new -s .
rake findit:install
````

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
