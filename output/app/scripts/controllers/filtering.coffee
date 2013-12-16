'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    ## EXTRACT common module functionality

    if $window.chrome
      $window.webbuddy.env.name = 'stub'

    # expose the scope so the hosting environment can interact with the view.
    # use flat keys to avoid timing dependencies.
    $window.webbuddy_data_updated = ->
      $scope.refresh_data()

    # view consts. UNUSED
    $scope.partials =
      collection: 'views/collection.html'


    # # isotope bits. UNUSED
    # isotope_containers = [ '.search-list', '.page-list', '.suggestion-list' ]
    # $scope.options =
    #   itemSelector: '.item'
    #   layoutMode: 'straightDown'
    #   # layoutMode: 'straightAcross'
    # # initialise isotope.
    # $scope.isotope = (selector_for_container, options = $scope.options)->
    #   # $timeout ->
    #   #   # re-isotope
    #   #   $(selector_for_container).isotope options

    #   #   # hide elems after limit
    #   #   # $(selector_for_container).find('.item:gt(4)').
    #   # , 0


    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      $scope.filter()
    # FIXME when this code path throws, it will be silent from webbuddy. not good

    ## view ops.

    $scope.refresh_data = ->
      $timeout ->
        console.log "refreshing data."
        $scope.data = $window.webbuddy_data
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
      $scope.view_model.searches = $scope.data?.searches?.filter (search)->
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


      # update the selected one.
      $scope.preview $scope.view_model.hits[0]
      # $scope.$apply()

      # isotope_containers.map (selector)->
      #   $scope.isotope $(selector)
      #   $(selector).isotope 'reloadItems'

    $scope.classname = (item) ->
      if $scope.view_model.selected_item is item
        'selected'
      else
        ''


    ## statics
    $scope.view_model ||=
      limit: 5
      # show_dev: true
      show_dev: webbuddy.env.name is 'stub'


    ## doit.
    # FIXME make polymorphic.
    switch webbuddy.env.name
      when 'stub'
        Restangular.setBaseUrl("data");
        Restangular.one('filtering.json').get().then (data)->

          # guard against a race from the attach op.
          unless $window.webbuddy_data
            $window.webbuddy_data = data

            $scope.refresh_data()

      else
        $scope.refresh_data()


    # isotope doit. UNUSED
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

        # work around cyclic refs tripping up JSON.stringify
        eval_result = JSON.decycle eval_result

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

    # quick-hack terminal transformation to ensure recursive rendering succeeds.
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
