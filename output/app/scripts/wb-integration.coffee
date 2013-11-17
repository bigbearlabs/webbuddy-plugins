window.webbuddy =
  env:
    name: 'webbuddy'
  
  log: ->
    # TODO


  module:
    update_data: (data)->
      setTimeout ->
        webbuddy.module.data = data
        webbuddy.module.data_updated data
      , 0
    
    update_property: (prop, val)->
      unless webbuddy.module.data
        throw "data hasn't been set."

      webbuddy.module.data[prop] = val
      webbuddy.module.data_updated val

    # modules to redefine this.
    data_updated: (data)->
      throw "module should set webbuddy.module.data_updated";
