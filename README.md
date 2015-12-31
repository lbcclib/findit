# FindIt

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), with a few other gems thrown in.  This repository represents the changes we made from a basic installation of blacklight.

You should be able to complete Blacklight's easy install to create a basic discovery layer.  Then git pull this into a directory where you've installed blacklight.  Index some data, and you'll be able to replicate our discovery layer.  In theory, this should work on Windows and Linux boxes using [Ruby or JRuby](https://github.com/sandbergja/discovery_layer/issues/60), but has only been tested with JRuby on Windows Server 2013.
