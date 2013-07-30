#!/usr/bin/env ruby
require 'rvm'
require 'dotenv'
require 'erubis'

def osx?
  RUBY_PLATFORM.downcase =~ /darwin/
end

# This script will create a fully-working gov.uk-style setup locally

`./make_env`
Dotenv.load './env'

organisation = 'theodi'

projects     = {
  'signonotron2' =>     'signon',
  'static' =>           'static',
  'panopticon' =>       'panopticon',
  'publisher' =>        'publisher',
  'content_api' =>      'contentapi',
  'people' =>           'people',
  'frontend' =>         'private-frontend',
  'frontend-news' =>    'news',
  'frontend-www' =>     'www',
  'frontend-courses' => 'courses'
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

def make_vhost ourname, port
  if osx?
    # Add pow symlink
    system "rm ~/.pow/#{ourname}"
    command = "ln -sf %s/%s ~/.pow/%s" % [
      Dir.pwd,
      ourname,
      ourname
    ]
    system command
  else
    template = File.read("templates/vhost.erb")
    template = Erubis::Eruby.new(template)
    f = File.open "#{ourname}/vhost", "w"
    f.write template.result(
      :servername => ourname,
      :port => port,
      :domain => ENV['GOVUK_APP_DOMAIN'],
    )
    f.close

    command = "sudo rm -f /etc/nginx/sites-enabled/%s" % [
      ourname
    ]
    system command

    command = "sudo ln -sf %s/%s/vhost /etc/nginx/sites-enabled/%s" % [
      Dir.pwd,
      ourname,
      ourname
    ]
    system command
  end
end
  
puts green "We're going to grab all the actual applications we need."

pwd = `pwd`.strip

port = 3000
projects.each_pair do |theirname, ourname|
  if not Dir.exists? ourname.to_s
    puts "%s %s %s %s" % [
      green("Cloning"),
      red(theirname),
      green("into"),
      red(ourname)
    ]
    system "git clone git@github.com:#{organisation}/#{theirname}.git #{ourname}"
  else
    puts "%s %s" % [
      green("Updating"),
      red(ourname)
    ]
    system "cd #{ourname} && git pull origin master && cd ../"
  end    
  
  puts "%s %s" % [
    green("Bundling"),
    red(ourname)
  ]

  system "rvm in #{ourname} do bundle"
  env_path = "%s/env" % [
    Dir.pwd,
  ]
  system "rm -f #{ourname}/.env"
  system "ln -sf #{env_path} #{ourname}/.env"
  if File.exists? "%s/Procfile" % [
    ourname
  ]

    puts "%s %s" % [
      green("Generating upstart scripts for"),
      red(ourname)
    ]
   
    Dir.chdir ourname.to_s do
      command = "rvm in . do rvmsudo bundle exec foreman export -a %s -u %s -p %d upstart /etc/init" % [
        ourname,
        `whoami`.strip,
        port
      ]
      system command
    end
  end

  make_vhost ourname, port

  port += 1000
end

projects.each_pair do |theirname, ourname|
  puts "%s %s" % [
    green("Restarting"),
    red(ourname)
  ]
  `sudo service #{ourname} restart`
end

system "sudo service nginx restart"

# THINGS BEYOND HERE ARE DESTRUCTIVE
#exit
#system "ln -sf #{pwd}/frontend ~/.pow/private-frontend"

puts green "Now we need to generate application tokens in the signonotron."

def oauth_id(output)
  output.match(/config.oauth_id     = '(.*?)'/)[1]
end

def oauth_secret(output)
  output.match(/config.oauth_secret = '(.*?)'/)[1]
end

Dir.chdir("signon") do
  RVM.use! '.'

  puts green "Setting up signonotron database..."

#  system "mysqladmin -u root create signonotron2"
#  system "mysql -u root < ../db_setup.sql"

#  system "rake db:schema:load"
  
  puts green "Make signonotron work in dev mode..."

  system "bundle exec ./script/make_oauth_work_in_dev"
  
  puts "%s %s" % [
    green("Generating application keys for"),
    red("publisher")
  ]

  begin
    str = `rake applications:create name=Publisher description="Content editing" home_uri="http://publisher.#{ENV['GOVUK_APP_DOMAIN']}" redirect_uri="http://publisher.#{ENV['GOVUK_APP_DOMAIN']}/auth/gds/callback"`
    File.open('../oauthcreds', 'a') do |f|
      f << "PUBLISHER_OAUTH_ID=#{oauth_id(str)}\n"
      f << "PUBLISHER_OAUTH_SECRET=#{oauth_secret(str)}\n"
    end
  rescue
    nil
  end
  
  puts "%s %s" % [
    green("Generating application keys for"),
    red("panopticon")
  ]

  begin
    str = `rake applications:create name=Panopticon description="Metadata management" home_uri="http://panopticon.#{ENV['GOVUK_APP_DOMAIN']}" redirect_uri="http://panopticon.#{ENV['GOVUK_APP_DOMAIN']}/auth/gds/callback"`
    File.open('../oauthcreds', 'a') do |f|
      f << "PANOPTICON_OAUTH_ID=#{oauth_id(str)}\n"
      f << "PANOPTICON_OAUTH_SECRET=#{oauth_secret(str)}\n"
    end
  rescue
    nil
  end
  
  `./make_env`

  puts green "We'll generate a couple of sample users for you. You can add more by doing something like:"
  puts red "$ cd signon"
  puts red "$ rvm use ."
  puts red "$ GOVUK_APP_DOMAIN=#{ENV['GOVUK_APP_DOMAIN']} DEV_DOMAIN=#{ENV['DEV_DOMAIN']} bundle exec rake users:create name='Alice' email=alice@example.com applications=Publisher,Panopticon"

  system "GOVUK_APP_DOMAIN=#{ENV['GOVUK_APP_DOMAIN']} DEV_DOMAIN=#{ENV['DEV_DOMAIN']} bundle exec rake users:create name='Alice' email=alice@example.com applications=Publisher,Panopticon"
  system "GOVUK_APP_DOMAIN=#{ENV['GOVUK_APP_DOMAIN']} DEV_DOMAIN=#{ENV['DEV_DOMAIN']} bundle exec rake users:create name='Bob' email=bob@example.com applications=Publisher,Panopticon"
end

projects.each_pair do |theirname, ourname|
  `sudo service #{ourname} restart`
end

system "sudo service nginx restart"
