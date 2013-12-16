# for use only by webbuddy.

@webbuddy =
  env:
    name:
      if @WebKitJavascriptBridge
        'webbuddy'
      else
        'stub'


## set up some useful stuff.
@console.log ||= (msg...)=>
  # log using bridge. TODO replace with a function attached from hosting env.
  WebViewJavascriptBridge.send "console.log: #{msg}"


# interface elements:
# window.webbuddy_data
# window.webbuddy_data_updated

