angular.module('modulesApp').factory 'webbuddy', () ->
  webbuddy =
    to_hash: (array, key_property)->
      array.reduce (acc, e)->
        key = encodeURIComponent e[key_property]
        acc[key] = e
        acc
      , {}

    ## interfacing with hosting env.

    reg_on_data: (handler)->
      @handler = handler

    on_data: (new_data)->
      handler = @handler

      data = _.clone scope.data
      data ||= {}

      merge_deltas()

      handler(data)

    merge_deltas: ->
      for k, v of new_data

        if k.indexOf('_delta') >= 0
          # for keys /.*_delta/, merge values with existing key.

          k = k.replace '_delta', ''
          v_hash = to_hash v, 'name'

          delta_applied = _.clone data[k]
          for delta_k, delta_v of v_hash
            console.log "setting #{k}.#{delta_k} to #{delta_v}"
            delta_applied[delta_k] = delta_v

          data[k] = delta_applied
        else
          # just add to the data.

          console.log "setting #{k}"
          data[k] = v

