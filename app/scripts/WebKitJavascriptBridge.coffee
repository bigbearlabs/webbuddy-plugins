## set up WebViewJavascriptBridge.

connectWebViewJavascriptBridge = (callback) ->
  if window.WebViewJavascriptBridge
    callback WebViewJavascriptBridge
  else
    document.addEventListener "WebViewJavascriptBridgeReady", (->
      callback WebViewJavascriptBridge
    ), false


connectWebViewJavascriptBridge (bridge) ->

  # init with handler from hosting env
  bridge.init (message, responseCallback) ->
    console.log "Received message: " + message
    eval message
    responseCallback "Right back atcha"  if responseCallback

  # test some js->objc sends
  bridge.send "Hello from the javascript"
  bridge.send "Please respond to this", responseCallback = (responseData) ->
    console.log "Javascript got its response", responseData
