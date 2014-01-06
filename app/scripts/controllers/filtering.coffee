'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    # attach data handler to the bridge
    webbuddy.on_data = (new_data)->
      data = _.clone $scope.data
      data ||= {}

      for k, v of new_data

        if k.indexOf('_delta') >= 0
          # for keys /.*_delta/, merge values with existing key.

          k = k.replace '_delta', ''
          delta_applied = _.clone data[k]
          for delta_k, delta_v of v
            console.log "setting #{k}.#{delta_k} to #{delta_v}"
            delta_applied[delta_k] = delta_v

          data[k] = delta_applied
        else
          # just add to the data.

          console.log "setting #{k}"
          data[k] = v

      $scope.refresh_data data


    # # isotope bits. UNUSED
    isotope_containers = [ '.search-list', '.page-list', '.suggestion-list' ]

    $scope.isotope_options =
      itemSelector: '.hit-list > .item'
      layoutMode: 'straightDown'
      # layoutMode: 'straightAcross'

    # initialise isotope.
    $scope.isotope = (selector_for_container)->
      $timeout ->
        # re-isotope
        $(selector_for_container).isotope options, $scope.isotope_options

        # hide elems after limit
        # $(selector_for_container).find('.item:gt(4)').


    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      $scope.filter()
    # FIXME when this code path throws, it will be silent from webbuddy. not good

    ## view ops.

    $scope.refresh_data = (data)->
      $timeout ->
        # console.log "refreshing data: #{JSON.stringify data}"
        $scope.data = data
        $scope.filter()
        $scope.$apply()


    ## ui ops.

    $scope.preview = (item) ->
      $scope.view_model.selected_item = item
      $scope.view_model.details =
        if item
          name: item.name
          items: if item.pages then item.pages else [ item ]
        else
          null

    $scope.hide_preview = (item) ->
      $scope.view_model.details = null

    $scope.$root.filter = (input = $scope.data?.input)->
      # simulate an error to ensure hosting environment can report it.
      # throw "DING"

      console.log("filtering for #{input}")

      ## filter using isotope. UNUSED
      # options = {}
      # options.filter = ".item:contains(#{input})"

      # isotope_containers.map (selector)->
      #   $scope.isotope $(selector), options


      ## filter the view model.
      $scope.view_model.searches = _.chain($scope.data?.searches)
      .values()
      .sortBy( (e)-> (e.last_accessed_timestamp or 0) )
      .value()
      .reverse()
      .filter (search)->
        search.name?.toLowerCase().match input.toLowerCase()
      $scope.view_model.searches ||= []

      $scope.view_model.hits = _.clone $scope.view_model.searches

      $scope.view_model.pages = $scope.data?.pages?.filter (page)->
        page.name?.toLowerCase().match input.toLowerCase()

      if $scope.view_model?.pages?.length > 0
        page_stack =
          name: 'Matching pages'
          pages: $scope.view_model.pages

        $scope.view_model.hits.push page_stack


      # invoke preview on the selected one.
      $scope.preview $scope.view_model.hits[0]
      # $scope.$apply()

      # re-isotope. check to see if it's really needed
      # isotope_containers.map (selector)->
      #   $scope.isotope $(selector)
      #   $(selector).isotope 'reloadItems'


    $scope.classname = (item) ->
      classname =
        if $scope.view_model.selected_item is item
          'selected'
        else
          ''


    # dev-only
    $scope.fetch_stub_data = ->
      stub_data_rsc = 'filtering.json'
      console.log "fetch stub data from #{stub_data_rsc}"
      Restangular.setBaseUrl "data"
      Restangular.one(stub_data_rsc).get()
      .then (data)->
        $scope.refresh_data data


    ## statics
    $scope.view_model ||=
      limit: 5
      # show_dev: true
      show_dev: webbuddy.env.name is 'stub'


    ## doit.
    # FIXME make polymorphic.
    switch webbuddy.env.name
      when 'stub'
        $scope.fetch_stub_data()


    # isotope doit. UNUSED
    # isotope_containers.map (selector)->
    #  $scope.isotope selector
    #  $timeout ->
    #    $(selector).isotope()
    #  , 0

    # $window.webbuddy.module.update_data data


    # $scope.isotope()

    # , 0


