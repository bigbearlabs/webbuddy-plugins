## set up WebViewJavascriptBridge.

connectWebViewJavascriptBridge = (callback) ->
  if window.WebViewJavascriptBridge
    callback WebViewJavascriptBridge
  else
    document.addEventListener "WebViewJavascriptBridgeReady", (->
      callback WebViewJavascriptBridge
    ), false


connectWebViewJavascriptBridge (bridge) ->

  # init with handler for calls from hosting env: take care of objc->js messaging.
  bridge.init (message, responseCallback) ->
    console.log "Received message: " + message

    # by default, eval.
    eval message

    responseCallback "Right back atcha"  if responseCallback

  # test some js->objc messaging.
  bridge.send "Hello from the javascript"
  bridge.send "Please respond to this", responseCallback = (responseData) ->
    console.log "Javascript got its response", responseData
