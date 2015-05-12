task :default => :loop

task :release => [ :build ]


desc "loop"
task :loop do
  sh %(
    brunch watch --server -p 9000
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
      sh "slimrb #{file} #{target}"
    end
  end

  # CHROME
  # sh %Q(
  #   # work around the prefix ignored by brunch
  #   rsync -avvv app/assets/_locales build/
  # )
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
