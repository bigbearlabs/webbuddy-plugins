angular.module('app').service 'webbuddy', ($window) ->

  webbuddy =

    match_strategies:
      name_match: (e, input)->
        if input == undefined or input.length is 0
          return true

        # case-insensitive to_data of names.
        e.name?.toLowerCase().match input.toLowerCase()

      null_match: ->
        return true


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

          to_data[k] = delta_applied
        else
          # just add to the data.

          console.log "setting #{k}"
          to_data[k] = v


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

        # convert dates
        e.items.map (i) ->
          i.last_accessed_timestamp = new Date(i.last_accessed_timestamp)

        # set the collection's date
        e.last_accessed_timestamp = _.max e.items.map((e)-> e.last_accessed_timestamp)

        # this will get elaborated on.


      # TODO concat other types of data as they are finished.


    ## interfacing with hosting env.

    # FIXME working around in controller instead.
    reg_on_data: (fetch_data, handler)->
      on_data = (new_data)->
        data = _.clone fetch_data() or {}

        webbuddy.fold_data new_data, data
        webbuddy.update_items data

        handler(data)

      $window.webbuddy.on_data = on_data  # DIRTY HACK!
      # TODO remodel the bridge to have 2 clear sides.


    ## filtering strategies.
    match: (match_strategy, items, input = '')->
      items.filter (item)=>
        matched = match_strategy item, input
        # or
        # # any page matches.
        # item.pages?.filter((e)-> match_strategy e).length > 0

        matched

      # # return all searches as rendering is determined by class.
      # searches


    ## interfacing with angular controllers.
    smart_stacks: (stacks, input, callback)->

      all_pages = _.chain(stacks?.map (e)->e.pages).flatten().uniq().sortBy((e)->e.last_accessed_timestamp).reverse().value()

      smart_stacks = [
        name: "pages"
        items: @match @match_strategies['name_match'], all_pages, input
      ,
        name: "highlights"
        items: @match @match_strategies['name_match'], [
            name: 'stub item'
            url: 'stub-url'
            thumbnail_url: 'stub-thumbnail-url'
          ,
            name: 'lorem ipsum'
            url: 'stub-url'
            thumbnail_url: 'stub-thumbnail-url'
          ], input
        msg: 'Content highlighted during your web activity will show up here.'
        details_url: 'http://webbuddyapp.com/features/highlights'
      ,
        name: 'suggestions'
        items: []
        template: 'text-list.html'
      ]

      call_callback = ->
        # return ones with results.
        callback smart_stacks.filter((e)-> e.items.length > 0)

      if input?.length > 0
        try
          $.getJSON "http://suggestqueries.google.com/complete/search?callback=?",
            hl: "en" # Language
            jsonp: "suggestCallBack" # jsonp callback function name
            q: input # query term
            client: "youtube" # force youtube style response, i.e. jsonp

          ## get google suggestions.
          $window.suggestCallBack = (data) =>
            suggestions = _.values(data[1]).map((e)-> e[0]).map (suggestion) =>
              name: suggestion
              url: @to_search_url suggestion

            console.log "suggestions: #{suggestions.map (e)->e.name}"
            smart_stacks[2].items = suggestions

            call_callback()
        catch e
          console.log "error during suggest queries fetch: #{e}"
          call_callback()
      else
        call_callback()


    #= web-side event handlers.
    # TODO use arguments.callee.name to dynamically dispatch.

    on_item_click: (item)->
      if $window.objc_interface
        $window.objc_interface.on$_item$_click_(item)
      else
        console.log "TODO: load #{item}"


    on_input_field_submit: (input) ->
      if $window.objc_interface
        $window.objc_interface.on$_input$_field$_submit_(input)
      else
        # do a google search.
        console.log "on_input_field_submit: falling back to web impl."
        @open_url @to_search_url(input)

    on_input_field_focus: ->
      console.log 'TODO focus'

    on_input_field_unfocus: ->
      console.log 'TODO unfocus'


    #= input handling

    open_url: (url) ->
      $window.location.assign url

    to_search_url: (query)->
      "http://google.com/search?q=#{query}"

    quote_input: (input, preceding_phrase = 'matching') ->
      if input?.length > 0
        " #{preceding_phrase} '#{input}'"
      else
        ''


    # end service def.


  # bridge from wb-integration -- copy all props from $window.webbuddy
  for k, v of $window.webbuddy
    webbuddy[k] = v

  webbuddy
