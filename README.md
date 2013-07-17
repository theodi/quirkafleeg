Quirkafleeg
===========

Project Quirkafleeg is the ODI's next-generation web publishing platform, mostly built 
atop GDS's excellent work on gov.uk.

At this point, it's mainly a single script that sets up a working collection of six gov.uk
applications, which together let you write, review, and publish information onto the frontend
site.

It uses:

* signonotron2
* static
* panopticon
* publisher
* govuk_content_api
* frontend

(currently it uses ODI forks for these, but once PRs are accepted it should work with the alphagov version)

Requirements
------------

* OSX
* Homebrew
* Ruby 1.9.3 installed via [RVM](http://rvm.io)

Perform a Quirkafleeg!
----------------------

*WARNING: THIS WILL PROBABLY BE VERY RUDE TO ANY LOCAL MONGODB OR MYSQL YOU HAVE INSTALLED*

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
