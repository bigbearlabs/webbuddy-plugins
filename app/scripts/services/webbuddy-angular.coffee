angular.module('modulesApp').factory 'webbuddy', () ->
  webbuddy =

    ## data transformations.

    to_hash: (array, key_property)->
      array.reduce (acc, e)->
        key = encodeURIComponent e[key_property]
        acc[key] = e
        acc
      , {}

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


    ## interfacing with hosting env.

    reg_on_data: (handler)->
      @handler = handler
      # smells.

    on_data: (new_data)->
      handler = @handler

      data = _.clone scope.data
      data ||= {}

      merge_deltas()

      handler(data)


    ## filtering strategies.
    match: (match_strategy_name, searches, input = '')->
      @name_match ||= (e, input)->
        if input.length is 0
          return true

        # case-insensitive match of names.
        e.name?.toLowerCase().match input.toLowerCase()


      match_strategy = @[match_strategy_name]
      searches.filter (search)->
        matched = match_strategy search, input
        # or
        # # any page matches.
        # search.pages?.filter((e)-> match_strategy e).length > 0

        # update the view model item.
        search.matched = matched

        matched

      # # return all searches as rendering is determined by class.
      # searches


    ## interfacing with angular controllers.
    update_smart_stacks: ->
      # update_stack 'Pages',
      #   (matcher)->
      #     $scope.data.stacks.map((e)-> e.pages).filter (page)->
      #       matcher.match page


    # end service def.

  # bridge from wb-integration -- copy all props from window.webbuddy
  for k, v of window.webbuddy
    webbuddy[k] = v

  webbuddy
