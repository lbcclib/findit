# Find It

Find It is a discovery layer for [Linn-Benton Community College's library](http://library.linnbenton.edu/).  This tool searches across most of the library's print and electronic resources so that students don't get stuck in just one silo of information.

Find It is based on [Blacklight](http://projectblacklight.org/), Postgres, and various other projects.

## Creating a FindIt Dev Environment

Here's how to get this running for yourself:

```
git clone https://github.com/lbcclib/findit
cd findit
docker-compose up -d
docker-compose exec app bin/rake db:migrate findit:data:index:sample
```

You can then see FindIt in your browser at localhost:3000.  You can make changes to the local directory, and it will be reflected in docker.  You may need to restart the app container for certain changes to take effect: `docker-compose restart app`


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
mySession = EdsService.connect

article = {dbid:'a9h', an: 138929081'}
mySession.retrieve article #retrieve an article

EdsService.blacklight_style_search ActionController::Parameters.new({
  page: 2,
  q: 'Britney Spears'}) #get some search results
```
