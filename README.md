# FindIt

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), with a few other gems thrown in.  This repository represents the changes we made from a basic installation of blacklight.

In theory, you should be able to get this to work on Windows and Linux boxes using [Ruby or JRuby](https://github.com/sandbergja/discovery_layer/issues/60), but has only been tested in the following environments:

* JRuby on Windows Server 2013
* Ruby on Ubuntu 15.10

Here's how to get this running for yourself:

1. Follow the Blacklight [Quickstart install instructions](https://github.com/projectblacklight/blacklight/wiki/Quickstart).  Use the "hard way", rather than the one-liner to get your app started.  Make sure to include Devise in this installation process.
2. `cd` into the directory that you created.
4. `git init`
5. `git remote add findit [URL]` where [URL] is the name of this repository.
6. `git pull findit master`
7. `git reset --hard findit/master`
8. Add jettywrapper to the Gemfile.
8. `bundle install` to make sure you have all the correct gems installed.  You may have to do a few `bundle update` commands.
10. `rails generate ahoy:stores:active_record`
11. `rake db:migrate`
