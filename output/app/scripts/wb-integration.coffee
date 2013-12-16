# for use only by webbuddy.

@webbuddy =
  env:
    name: 'webbuddy'

  module:
    update_data: (data)->
      webbuddy.module.data = data
      webbuddy.module.scope.refresh_data()
      webbuddy.module.scope.$apply()

    update_property: (prop, val)->
      unless webbuddy.module.data
        throw "data hasn't been set."

      webbuddy.module.data[prop] = val

      webbuddy.module.scope.refresh_data()
      webbuddy.module.scope.$apply()



## set up some useful stuff.
@console.log = (msg...)=>
  # log using bridge. TODO replace with a function attached from hosting env.
  WebViewJavascriptBridge.send "console.log: #{msg}"

