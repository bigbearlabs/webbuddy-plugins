task :default => [ :build, :assemble, :stage ]

desc "build"
task :build do
  sh 'grunt build'  # will build to dist/
end

desc "assemble"
task :assemble do
  sh 'rsync -av static/* app/data dist/'
end

desc "deploy to Google Drive"
task :stage do
  sh %(rsync -av --delete dist/* "#{ENV['HOME']}/Google Drive/bigbearlabs/webbuddy-preview/plugins/")
end
