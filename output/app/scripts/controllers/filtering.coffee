'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    ## EXTRACT common module functionality

    ## webbuddy global property
    # set up a stub hosting environment if it hasn't beeen set up already. EXTRACT
    $window.webbuddy ||=
      env:
        name: 'stub'
      module: {}

    # expose the scope so the hosting environment can interact with the view.
    $window.webbuddy.module.filter_scope = $scope

    # view consts. unused
    $scope.partials =
      collection: 'views/collection.html'

    # isotope bits
    isotope_containers = [ '.search-list', '.page-list', '.suggestion-list' ]
    $scope.options =
      itemSelector: '.item'
      layoutMode: 'straightDown'
      # layoutMode: 'straightAcross'
    # initialise isotope.
    $scope.isotope = (selector_for_container, options = $scope.options)->
      # $timeout ->
      #   # re-isotope
      #   $(selector_for_container).isotope options

      #   # hide elems after limit
      #   # $(selector_for_container).find('.item:gt(4)').
      # , 0



    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      $scope.filter $scope.data?.input


    ## view ops.

    $scope.refresh_data = ->
      $scope.data = $window.webbuddy.module.data
      $scope.$apply()

    ## ui ops.

    $scope.preview = (item) ->
      $scope.view_model.details =
        name: item.name
        items: if item.pages then item.pages else [ item ]

    $scope.hide_preview = (item) ->
      $scope.view_model.details = null

    $scope.$root.filter = (input)->
      ## filter using isotope.
      # options = {}
      # options.filter = ".item:contains(#{input})"

      # isotope_containers.map (selector)->
      #   $scope.isotope $(selector), options

      ## filter using view model.
      $scope.view_model.searches = $scope.data?.searches?.filter (search)->
        search.name?.toLowerCase().match input.toLowerCase()

      $scope.view_model.pages = $scope.data?.pages?.filter (page)->
        page.name?.toLowerCase().match input.toLowerCase()

      # isotope_containers.map (selector)->
      #   $scope.isotope $(selector)
      #   $(selector).isotope 'reloadItems'


    ## statics
    $scope.view_model ||=
      limit: 5
      show_dev: true
      # show_dev: webbuddy.env.name is 'stub'


    ## doit.
    switch webbuddy.env.name
      when 'stub'
        Restangular.setBaseUrl("data");
        Restangular.one('filtering.json').get().then (data)->

          $window.webbuddy.module.data = data

          $scope.refresh_data()
          # $scope.$apply()
      else
        $scope.refresh_data()


    # isotope_containers.map (selector)->
    #  $scope.isotope selector
    #  $timeout ->
    #    $(selector).isotope()
    #  , 0

    # $window.webbuddy.module.update_data data


    # $scope.isotope()

    # , 0


# EXTRACT
angular.module('modulesApp')
  .controller 'ObjTreeCtrl', ($scope) ->

    # dev features.
    $scope.evaluate = (expr) ->
      try
        eval_result = eval(expr)
        $scope.obj = {}
        $scope.obj[expr] = eval_result
      catch e
        e

    $scope.obj_keys = (val)->
      return [] if val is null

      if typeof val is 'object'
        # console.log "val: #{val}, type: #{typeof val}"
        Object.keys val
      else
        []

    $scope.to_displayable = (val)->
      return '<null>' if val is null

      switch typeof(val)
        when 'object'
          ''
        when 'function'
          String(val)
        # TODO arrays, other types falling under js quirks
        else
          val
