exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  conventions:
    assets:  /^app\/assets\/|app\/scripts\/injectees\//
    ignored: /^(bower_components\/bootstrap-less(-themes)?|app\/styles\/overrides|(.*?\/)?[_]\w*)/
  modules:
    definition: false
    wrapper: false
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(bower_components|vendor)/
      order:
        before: [
          'bower_components/lodash/lodash.js'
          'bower_components/jquery/jquery.js'
          'bower_components/angular/angular.js'
        ]

    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor|bower_components)/
      order:
        before: [
          'app/styles/app.scss'
        ]

    templates:
      joinTo:
        'js/dontUseMe' : /^app/ # dirty hack for Jade compiling.

  plugins:
    jade:
      pretty: yes # Adds pretty-indentation whitespaces to output (false by default)
    jade_angular:
      modules_folder: 'partials'
      locals: {}
    afterBrunch: [
      ''' # compile slim files
        ruby <<EOF
        path = 'app'
        Dir.glob("app/**/*.slim")do |file|
          target = file.gsub( /\.slim$/, '').gsub(%r(^app\/assets), '_public')
          # system "mkdir -p `dirname target`"
          system "slimrb #{file} #{target}"
        end
        EOF
      '''
    ]
  # Enable or disable minifying of result js / css files.
  minify: true

  overrides:
    production:
      paths:
        public: 'build'
