task :default => :loop

task :stage => [ :build, :'stage:heroku' ]

task :release => [ :build, :'stage:gdrive' ]


desc "loop"
task :loop do
  sh %(
    brunch watch --server -p 9002
  )
end


task :build do
  sh %Q(
    # build to build/
    brunch build --production

    # compile coffee
    find build/ -name '*.coffee' | xargs coffee -c
  )

  puts '# compile slim files'
  [ 'build' ].map do |path|
    Dir.glob("#{path}/**/*.slim") do |file|
      target = file.gsub( /\.slim$/, '')
      system "slimrb #{file} #{target}"
    end
  end

  # CHROME
  # sh %Q(
  #   # work around the prefix ignored by brunch
  #   rsync -avvv app/assets/_locales build/
  # )
end

desc "deploy to Google Drive"
task :'stage:gdrive' do
  # copy the entire project to ease collaboration with designers
  sh %(rsync -av --delete --exclude='.tmp' --exclude='.sass-cache' * "#{ENV['HOME']}/Google Drive/bigbearlabs/webbuddy/webbuddy-preview/webbuddy-plugins/")
end

desc "deploy to bbl-rails on heroku"
task :'stage:heroku' do
  sh %(
    echo "## copy to webbuddy-plugins"
    rsync -av --delete --no-implied-dirs build/* ../bbl-rails/public/webbuddy-plugins/
    cd ../bbl-rails
    echo "## commit"
    git add -A public/webbuddy-plugins
    git ci -a -m "updating webbuddy-plugins, #{Date.new.to_s}"
    git push heroku
    echo "## pushed to heroku"
  )

  puts "## visit http://bbl-rails.herokuapp.com/webbuddy-plugins/index.html to test staged build."
end

desc "clean"
task :clean do
  sh %(
    rm -rf build/
  )
end

desc 'bootstrap'
task :'bootstrap' do
  sh %(
    # needs npm, bower.
    npm install -g grunt-cli
    npm install -g grunt
    npm install -g brunch
    npm install
    bower install
  )
end
