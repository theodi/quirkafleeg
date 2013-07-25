#!/usr/bin/env ruby
require 'rvm'

# This script will create a fully-working gov.uk-style setup locally

organisation = 'theodi'

projects     = {
  signonotron2:      'signon',
  static:            'static',
  panopticon:        'panopticon',
  publisher:         'publisher',
  content_api:       'contentapi',
  frontend:          'www',
}

def colour text, colour
  "\x1b[%sm%s\x1b[0m" % [
    colour,
    text
  ]
end

def red text
  colour text, "31"
end

def green text
  colour text, "32"
end
  
puts green "We're going to grab all the actual applications we need."

pwd = `pwd`.strip

port = 9000
projects.each_pair do |project, servername|
  if not Dir.exists? project.to_s
    puts "%s %s" % [
      green("Cloning"),
      red(project)
    ]
    system "git clone git@github.com:#{organisation}/#{project}.git"
  else
    puts "%s %s" % [
      green("Updating"),
      red(project)
    ]
    system "cd #{project} && git pull && cd ../"
  end    
  
  puts "%s %s" % [
    green("Bundling"),
    red(project)
  ]

  system "rvm in #{project} do bundle"
  system "ln -sf env #{project}/.env"
  if File.exists? "%s/Procfile" % [
    project
  ]

    puts "%s %s" % [
      green("Generating upstart scripts for"),
      red(project)
    ]
   
    Dir.chdir project.to_s do
      command = "rvm in . do rvmsudo bundle exec foreman export -a %s -u %s -p %d upstart /etc/init" % [
        project,
        `whoami`.strip,
        port
      ]
      system command
    end
  end

  port += 1000
end

#system "ln -sf #{pwd}/frontend ~/.pow/private-frontend"

puts green "Now we need to generate application tokens in the signonotron."

def oauth_id(output)
  output.match(/config.oauth_id     = '(.*?)'/)[1]
end

def oauth_secret(output)
  output.match(/config.oauth_secret = '(.*?)'/)[1]
end

Dir.chdir("signonotron2") do
  RVM.use! '.'

  puts green "Setting up signonotron database..."

  system "mysqladmin -u root create signonotron2"
  system "mysql -u root < ../db_setup.sql"

  system "RACK_ENV=production rake db:schema:load"
  
  puts green "Make signonotron work in dev mode..."

  system "bundle exec ./script/make_oauth_work_in_dev"
  
  puts "%s %s" % [
    green("Generating application keys for"),
    red("publisher")
  ]

  str = `rake applications:create name=Publisher description="Content editing" home_uri="http://publisher.dev" redirect_uri="http://publisher.dev/auth/gds/callback"`
  File.open('../env', 'a') do |f|
    f << "export PUBLISHER_OAUTH_ID=#{oauth_id(str)}\n"
    f << "export PUBLISHER_OAUTH_SECRET=#{oauth_secret(str)}\n"
  end
  
  puts "%s %s" % [
    green("Generating application keys for"),
    red("panopticon")
  ]

  str = `rake applications:create name=Panopticon description="Metadata management" home_uri="http://panopticon.dev" redirect_uri="http://panopticon.dev/auth/gds/callback"`
  File.open('../env', 'a') do |f|
    f << "export PANOPTICON_OAUTH_ID=#{oauth_id(str)}\n"
    f << "export PANOPTICON_OAUTH_SECRET=#{oauth_secret(str)}\n"
  end
  
  puts green "We'll generate a couple of sample users for you. You can add more by doing something like:"
  puts red "$ cd signonotron2"
  puts red "$ rvm use ."
  puts red "$ bundle exec rake users:create name='Alice' email=alice@example.com applications=Publisher,Panopticon"

  system "GOVUK_APP_DOMAIN=dev DEV_DOMAIN=dev bundle exec rake users:create name='Alice' email=alice@example.com applications=Publisher,Panopticon"
  system "GOVUK_APP_DOMAIN=dev DEV_DOMAIN=dev bundle exec rake users:create name='Bob' email=bob@example.com applications=Publisher,Panopticon"
end

