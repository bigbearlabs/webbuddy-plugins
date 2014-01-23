task :default => :loop

task :release => [ :build, :assemble, :stage ]

task :heroku => [ :build, :assemble, :'stage:heroku' ]

desc "loop"
task :loop do
  sh '''
    brunch watch --server -p 9000
  '''
end

desc "build"
task :build do
  sh '''
    # grunt build  # will build to _public/
    # rsync -av app/scripts/vendor _public/scripts/  # ship vendored scripts
    brunch build --production
  '''
end

desc "assemble"
task :assemble do
  sh '''
    ## ship static/, app/data, .tmp/scripts/injectees
    rsync -av static/* _public/
    ## assume bbl-middleman is built, ship intro.
    rsync -av ../bbl-middleman/build/webbuddy/intro _public/
  '''
end

desc "deploy to Google Drive"
task :stage do
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
