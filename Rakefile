task :default => [ :build, :assemble ]

desc "build"
task :build do
  sh 'grunt build'  # will build to dist/
end

desc "assemble"
task :assemble do
  sh 'rsync -av static/* data dist/'
end

desc "deploy to dropbox"
task :dropbox do
  sh 'rsync -av --delete dist/* ~/Dropbox/bigbearlabs/builds/webbuddy-modules/'
end
