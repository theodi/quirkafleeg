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
    # Symlink powrc file to load rvm correctly
    command = "ln -sf %s/powrc %s/%s/.powrc" % [
      Dir.pwd,
      Dir.pwd,
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

  unless osx?
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
  end

  make_vhost ourname, port

  port += 1000
end

# THINGS BEYOND HERE ARE DESTRUCTIVE
#exit

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

  system "rake db:migrate"
  
  puts green "Make signonotron work in dev mode..."

  system "bundle exec ./script/make_oauth_work_in_dev"
  
  apps = {
    'panopticon' => 'metadata management',
    'publisher' => 'content editing',
  }
  apps.each_pair do |app, description|

    puts "%s %s" % [
      green("Generating application keys for"),
      red(app)
    ]

    begin
      str = `rake applications:create name=#{app} description="#{description}" home_uri="http://#{app}.#{ENV['GOVUK_APP_DOMAIN']}" redirect_uri="http://#{app}.#{ENV['GOVUK_APP_DOMAIN']}/auth/gds/callback"`
      File.open('../oauthcreds', 'a') do |f|
        f << "#{app.upcase.gsub('-','_')}_OAUTH_ID=#{oauth_id(str)}\n"
        f << "#{app.upcase.gsub('-','_')}_OAUTH_SECRET=#{oauth_secret(str)}\n"
      end
    rescue
      nil
    end

  end
  
  `./make_env`

  puts green "We'll generate a couple of sample users for you. You can add more by doing something like:"
  puts red "$ cd signon"
  puts red "$ rvm use ."
  puts red "$ GOVUK_APP_DOMAIN=#{ENV['GOVUK_APP_DOMAIN']} DEV_DOMAIN=#{ENV['DEV_DOMAIN']} bundle exec rake users:create name='Alice' email=alice@example.com applications=#{apps.keys.join(',')}"

  {
    'alice' => 'alice@example.com',
    'bob' => 'bob@example.com',
  }.each_pair do |name, email|
    begin
      system "GOVUK_APP_DOMAIN=#{ENV['GOVUK_APP_DOMAIN']} DEV_DOMAIN=#{ENV['DEV_DOMAIN']} bundle exec rake users:create name='#{name}' email=#{email} applications=#{apps.keys.join(',')}"
    rescue
      nil
    end
  end
  
end

projects.each_pair do |theirname, ourname|
  if osx?
    system "mkdir -p #{ourname}/tmp"
    system "touch #{ourname}/tmp/restart.txt"
  else
    `sudo service #{ourname} restart`
  end
end

unless osx?
  system "sudo service nginx restart"
end
