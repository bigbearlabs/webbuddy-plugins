task :default => [ :build, :assemble ]

desc "build"
task :build do
  sh 'grunt build'  # will build to dist/
end

desc "assemble"
task :assemble do
  sh 'rsync -av static/* dist/'
end
