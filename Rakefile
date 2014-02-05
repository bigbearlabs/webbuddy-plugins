task :default => :loop

task :stage => [ :build, :assemble, :'stage:heroku' ]

task :release => [ :build, :assemble, :'stage:gdrive' ]


desc "loop"
task :loop do
  sh %(
    brunch watch --server -p 9000
  )
end


desc "build"
task :build do
  sh %(
    npm install
    bower install
    brunch build --production  # will build to _public
    find _public -name '*.coffee' | xargs coffee -c  # compile coffee
  )
end

desc "assemble"
task :assemble do
  sh %(
    ## ship static/, app/data, .tmp/scripts/injectees
    rsync -av static/* _public/
    ## assume bbl-middleman is built, ship intro.
    rsync -av ../bbl-middleman/build/webbuddy/intro _public/
  )
end

desc "deploy to Google Drive"
task :'stage:gdrive' do
  # copy the entire project to ease collaboration with designers
  sh %(rsync -av --delete --exclude='.tmp' --exclude='.sass-cache' * "#{ENV['HOME']}/Google Drive/bigbearlabs/webbuddy-preview/webbuddy-plugins/")
end

desc "deploy to bbl-rails on heroku"
task :'stage:heroku' do
  sh %(
    echo "## copy to webbuddy-plugins"
    rsync -av --delete --no-implied-dirs _public/* ../bbl-rails/public/webbuddy-plugins/
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
    rm -rf _public
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
