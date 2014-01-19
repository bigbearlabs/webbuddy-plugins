angular.module('modulesApp').factory 'webbuddy', () ->
  webbuddy =

    ## data transformations.

    to_hash: (array, key_property)->
      array.reduce (acc, e)->
        key = encodeURIComponent e[key_property]
        acc[key] = e
        acc
      , {}

    fold_data: (new_data, to_data)->
      for k, v of new_data

        if k.indexOf('_delta') >= 0
          # for keys /.*_delta/, merge values with existing key.

          k = k.replace '_delta', ''
          v_hash = @to_hash v, 'name'

          delta_applied = _.clone to_data[k]
          for delta_k, delta_v of v_hash
            console.log "setting #{k}.#{delta_k} to #{delta_v}"
            delta_applied[delta_k] = delta_v

          data[k] = delta_applied
        else
          # just add to the data.

          console.log "setting #{k}"
          data[k] = v


    transform_data: (data) ->
      ## process the data a bit.

      # convert searches into hash for easy delta application.
      if data.searches instanceof Array
        data.searches = @to_hash data.searches, 'name'

      # update the items property.
      @update_items data

      data


    update_items: (data) ->
      _.values(data.searches).map (e) ->
        e.items = e.pages


      # TODO concat other types of data as they are finished.


    ## interfacing with hosting env.

    reg_on_data: (handler, scope)->
      @handler = handler
      @scope = scope
      # smells.

    # TODO needs to be exposed to the host-env side of the bridge.
    on_data: (new_data)->
      handler = @handler

      data = _.clone @scope.data
      data ||= {}

      @fold_data new_data, data
      @update_items to_data

      handler(data)


    ## filtering strategies.
    match: (match_strategy_name, items, input = '')->
      @name_match ||= (e, input)->
        if input.length is 0
          return true

        # case-insensitive to_data of names.
        e.name?.toLowerCase().match input.toLowerCase()


      match_strategy = @[match_strategy_name]
      items.filter (item)->
        matched = match_strategy item, input
        # or
        # # any page matches.
        # item.pages?.filter((e)-> match_strategy e).length > 0

        # update the view model item.
        item.matched = matched

        matched

      # # return all searches as rendering is determined by class.
      # searches


    ## interfacing with angular controllers.
    smart_stacks: (stacks)->
      [
        name: 'Pages'
        items: _.chain(stacks?.map (e)->e.pages).flatten().uniq().value()

        # need to consolidate matching algos somehow.
        # matcher: (matcher)->
        #   $scope.data.stacks.map((e)-> e.pages).filter (page)->
        #     matcher.match page
      ,
        name: 'Highlights'
        items: []
      ,
        name: 'Search suggestions'
        items: []
      ]

    # end service def.

  # bridge from wb-integration -- copy all props from window.webbuddy
  for k, v of window.webbuddy
    webbuddy[k] = v

  webbuddy
