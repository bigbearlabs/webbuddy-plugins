task :default => [ :build, :assemble, :stage ]

task :heroku => [ :build, :assemble, :'stage:heroku' ]

desc "build"
task :build do
  sh '''
    grunt build  # will build to dist/
    rsync -av app/scripts/vendor dist/scripts/  # ship vendored scripts
  '''
end

desc "assemble"
task :assemble do
  sh '''
    ## ship static/, app/data, .tmp/scripts/injectees
    rsync -av static/* app/data .tmp/scripts/injectees dist/
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
    rsync -av --delete --no-implied-dirs dist/* ../bbl-rails/public/webbuddy-plugins/
    cd ../bbl-rails
    echo "## commit"
    git add -A public/webbuddy-plugins
    git ci -a -m "updating webbuddy-plugins, #{Date.new.to_s}"
    git push heroku
    echo "## pushed to heroku"
  )
end
