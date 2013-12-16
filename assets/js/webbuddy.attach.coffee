# if (!window.webbuddy)
#   #throw "window.webbuddy already set!"
#   window.webbuddy = {
#     module: {}
#   }

# window.webbuddy.env = {
#   name: 'webbuddy'
# }
# window.webbuddy.log = function() {}
# window.webbuddy.module.data = {
#   data: #{self.data.to_json}
# }

# return webbuddy

window.webbuddy =
  env:
    name: 'webbuddy'
  log: ->
    #

  module: {}
