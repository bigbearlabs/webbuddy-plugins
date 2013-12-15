## set up WebViewJavascriptBridge.

connectWebViewJavascriptBridge = (callback) ->
  if window.WebViewJavascriptBridge
    callback WebViewJavascriptBridge
  else
    document.addEventListener "WebViewJavascriptBridgeReady", (->
      callback WebViewJavascriptBridge
    ), false


connectWebViewJavascriptBridge (bridge) ->

  # Init your app here

  # init with handler from hosting env
  bridge.init (message, responseCallback) ->
    alert "Received message: " + message
    responseCallback "Right back atcha"  if responseCallback

  # test some js->objc sends
  bridge.send "Hello from the javascript"
  bridge.send "Please respond to this", responseCallback = (responseData) ->
    console.log "Javascript got its response", responseData



## set up some useful stuff.
@console.log = (msg...)=>
  # log using bridge. TODO replace with a function attached from hosting env.
  WebViewJavascriptBridge.send "console.log: #{msg}"



## setup @webbuddy.
