# for use only by webbuddy.

# represents the environment from the POV of plugins / other webkit-side artifacts.
@webbuddy =
  # default env.
  env:
    name: 'stub'
    show_dev: true

    data_pattern: 'data/#{name}.json'

  envs: [
    name: 'webbuddy'
    show_dev: false
  ,
  ]


  log: (msg...)=>
    @WebViewJavascriptBridge.send "console.log: #{msg}"

  on_event: (name, data = {}) =>
    event = { name, data }
    @WebViewJavascriptBridge.send "webbuddy_event: #{JSON.stringify(event)}"

  data: {}

post_bridge_attach = =>
  @webbuddy.env = @webbuddy.envs.filter((e)-> e.name == 'webbuddy')[0]


  ## set up some useful stuff.
  @console.log = @webbuddy.log

  # PROTOCOL send ready event to hosting env.
  @webbuddy.on_event 'bridge_attached'


if @WebViewJavascriptBridge
  post_bridge_attach()
else
  document.addEventListener "WebViewJavascriptBridgeReady", post_bridge_attach, false



# interface elements:
# window.webbuddy_data
# window.webbuddy_data_updated

