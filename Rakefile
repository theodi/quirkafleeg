task :default => [:update]

# NOTE: this is borrowed from setup.rb ... we should probably bundle the utilities and move them to lib/
#
projects     = {
  'signonotron2' =>     'signon',
  'static' =>           'static',
  'panopticon' =>       'panopticon',
  'publisher' =>        'publisher',
  'asset-manager' =>    'asset-manager',
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

desc "Update all repos"
task :update do
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
  end
end

