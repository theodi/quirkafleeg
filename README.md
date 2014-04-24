Quirkafleeg  
===========

Project Quirkafleeg is the ODI's next-generation web publishing platform, mostly built
atop GDS's excellent work on gov.uk.

At this point, it's mainly a single script that sets up a working collection of seven gov.uk
applications, which together let you write, review, and publish information onto the frontend
site.

It uses:

* signonotron2
* static
* panopticon
* publisher
* govuk_content_api
* rummager (for search)
* various frontend apps

(currently it uses ODI forks for these, but once PRs are accepted it should work with the alphagov version)

Requirements
------------

### OSX

* Homebrew
* Ruby 1.9.3 installed via [RVM](http://rvm.io)
* Pow installed from [pow.cx](http://pow.cx). [Anvil](http://anvilformac.com) is also useful.
* MongoDB installed and running: `brew install mongodb ; mongod`
* ElasticSearch: `brew install elasticsearch-0.20 ; echo 'alias es="elasticsearch -f -D es.config=/usr/local/opt/elasticsearch-0.20/config/elasticsearch.yml"' >> ~/.bashrc ; elasticsearch -f -D es.config=/usr/local/opt/elasticsearch-0.20/config/elasticsearch.yml`\*

\* This will run the ElasticSearch service, so you'll need to configure it as a background process, or keep it running and run the setup stuff in a seperate window. You can always start ElasticSearch again using the alias `es`, which will be set up in your `.bashrc` file

### Linux

* Stuff. Sam knows. Kind of.

Perform a Quirkafleeg!
----------------------

*WARNING: THIS WILL PROBABLY BE VERY RUDE TO ANY LOCAL MONGODB YOU HAVE INSTALLED*

*TREAD CAREFULLY IF YOU HAVE DATA YOU ARE AFRAID OF LOSING*

To get all your gov.uk ducks in a row, just:

```
git clone git://github.com/theodi/quirkafleeg.git
cd quirkafleeg
./setup.rb
```

If you find any problems (this hasn't been widely tested), please open an issue!

Future
------

This will probably morph into a Vagrant configuration at some point. This Ruby script is very much an interim measure.

License
-------

This code is open source under the MIT license. See the LICENSE.md file for full details.
