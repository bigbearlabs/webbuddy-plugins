angular.module('app').service 'host_env', ($window, $q, Restangular) ->

  envs =
    stub:
      get: (id)->
        console.log "TODO get"

        # stub
        {
          description: 'stub timer'
        }

      update: (id, data) ->
        console.log "TODO update timer data: #{data}"

    motion_kit:

      get: (id)->
        msg =
          get: id

        # url = "perform?op=send_data&data=#{encodeURIComponent(JSON.stringify data)}"
        # Restangular.oneUrl('send_data', url).get()
        # # .then ->
        # #   console.log 'xhr call for send_data finished.'

        deferred = $q.defer()

        $window.WebViewJavascriptBridge.send msg, (data) ->
          deferred.resolve data

        deferred.promise


      update: (id, data) ->
        console.log "TODO update timer data: #{data}"




  # end service obj def.


  envs.motion_kit
  envs.stub  # DEV
