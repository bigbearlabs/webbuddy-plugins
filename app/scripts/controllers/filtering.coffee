# TODO move out integration with host env into a service or module.
# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    ## interfacing with hosting env.

    to_hash = (array, key_property)->
      array.reduce (acc, e)->
        key = encodeURIComponent e[key_property]
        acc[key] = e
        acc
      , {}

    # attach data handler to the bridge
    webbuddy.on_data = (new_data, scope = $scope)->
      data = _.clone scope.data
      data ||= {}

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

      scope.refresh_data data
      scope.$apply()

    # FIXME refactor the above into a service that represents the host env.


    ## view-model observations.

    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      # filter data
      $scope.filter()


      # $scope.highlight()  # PERF

    # FIXME when this code path throws, it will be silent from webbuddy. not good


    ## view-model ops.

    $scope.refresh_data = (data)->
      ## process the data a bit. REFACTOR

      # convert searches into hash for easy delta application.
      if data.searches instanceof Array
        data.searches = to_hash data.searches, 'name'


      $timeout ->
        # console.log "refreshing data: #{JSON.stringify data}"

        $scope.data = data
        $scope.filter()
        $scope.$apply()
        # FIXME this will potentially trigger filtering twice after the watch on data.input


    # for serious development in coffeescript, we need a way to extract stuff like this into separate code modules really quickly. still looking for an agile enough solution.

    name_match = (e, input)->
      if input.length is 0
        return true

      # case-insensitive match of names.
      e.name?.toLowerCase().match input.toLowerCase()

    $scope.matching_searches = (searches, input = '')->
      searches.filter (search)->
        matched = name_match search, input
        # or
        # # any page matches.
        # search.pages?.filter((e)-> name_match e).length > 0

        # update the view model item.
        search.matched = matched

        matched

    # $scope.matching_searches_expr = $scope.matching_searches.toString()

    # $scope.update_matching_searches = (expr = $scope.matching_searches_expr) ->
    #   eval """
    #     angular.element('.master').scope().matching_searches = #{expr};
    #   """

    ## ui ops.

    $scope.classes = (item) ->
      hit: item.matched
      selected: $scope.view_model.selected_item == item


    $scope.highlight = (input = $scope.data?.input) ->
      $timeout ->
        # apply highlights. BAD-DEP
        $('body').highlightRegex()
        $('body').highlightRegex new RegExp input, 'i'


    $scope.preview = (item) ->
      $scope.view_model.selected_item = item
      $scope.view_model.detail =
        if item
          name: item.name
          items: if item.pages then item.pages else [ item ]
        else
          null

    $scope.hide_preview = (item) ->
      $scope.view_model.detail = null


    update_search_hits = (sync_reference, sync_target)->
      unless sync_target
        $scope.view_model.hits = _.clone sync_reference
        return

      intersection = _.intersection sync_reference, sync_target
      to_add = _.difference sync_reference, intersection
      to_remove = _.difference sync_target, intersection

      # remove all in to_remove.
      for i in [(sync_target.length - 1)...-1]
        e = sync_target[i]
        if _.include to_remove, e
          sync_target.splice i, 1

      # add all i to_add.
      to_add.map (e)-> sync_target.push e

    update_smart_stacks = ->
      console.log 'todo'

    $scope.filter = (input = $scope.data?.input)->
      console.log("filtering for #{input}")

      ## filter the view model and update views.

      $scope.view_model.searches = $scope.matching_searches _.values($scope.data?.searches), $scope.data?.input

      # disable pages for now.
      # $scope.view_model.pages = $scope.data?.pages?.filter (page)->
      #   page.name?.toLowerCase().match input.toLowerCase()

      # update_search_hits $scope.view_model.searches, $scope.view_model.hits
      # $scope.view_model.hits = $scope.view_model.searches
      if $scope.data?.searches != $scope.view_model.hits
        $scope.view_model.hits = _.values $scope.data.searches
      # CLEANUP

      update_smart_stacks()

      # invoke preview on the first hit.
      $scope.preview $scope.view_model.searches[0]

      # # we must re-isotope to avoid errors from isotope due to deviation between model and jquery objs.
      $scope.refresh_collection '.hit-list'


    ## statics
    $scope.view_model ||=
      limit: 5
      sort: '-last_accessed_timestamp'
      show_dev: ->
        webbuddy.env.name is 'stub'

      # show_dev: true


    ## isotope bits.

    # collection_containers = [ '.search-list', '.page-list', '.suggestion-list' ]
    collection_containers = [ '.hit-list' ]

    $scope.collection_options =
      itemSelector: '.item'
      layoutMode: 'straightDown'
      # layoutMode: 'straightAcross'
      # sortBy: 'name'  # TEMP
      # getSortData:
      #   name: ($elem)-> $elem.find('a').attr('title')

    # initialise isotope.
    $scope.init_collection = (selector_for_container)->
      $timeout ->
        # $(selector_for_container).isotope $scope.collection_options

    $scope.refresh_collection = (selector_for_container)->
      $timeout ->
        # $(selector_for_container).isotope('reloadItems').isotope()
        #   $(selector_for_container).isotope
        #     filter: '.hit'


    ## doit.
    $scope.fetch_data = (data_url)->
      data_url ||= webbuddy.env.data_pattern.replace '#{name}', 'filtering'
      console.log "fetch data from #{data_url} (env #{webbuddy.env.name})"
      data_url = data_url.replace '://', '@scheme_token@'  # escape scheme.
      [ base_segs..., last_seg ] = data_url.split '/'
      base_url = base_segs.join('/').replace('@scheme_token@', '://')
      Restangular.setBaseUrl base_url
      Restangular.one(last_seg).get()
      .then (data)->
        $scope.refresh_data data

        # # isotope doit.
        collection_containers.map (selector)->
          $scope.init_collection selector
          # $timeout ->


    # queue op to allow the bridge to attach first.
    $timeout ->
      $scope.fetch_data()
    , 100



