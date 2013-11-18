'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

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



    # # kick it.
    # $timeout ->
    #   $scope.evaluate $scope.data?.dev_input
    # , 500

    ## ui ops.

    $scope.preview = (item) ->
      $scope.view_model.details =
        name: item.name
        items: if item.pages then item.pages else [ item ]


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


    ## webbuddy global property
    # set up a stub hosting environment if it hasn't beeen set up already. EXTRACT
    $window.webbuddy ||=
      env:
        name: 'stub'
      module: {}

    # define webbuddy.module  EXTRACT
    $window.webbuddy.module.data_updated = (data)->
      $scope.$root.data = data
      # $scope.$apply()


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
          webbuddy.module.data_updated data



    # isotope_containers.map (selector)->
    #  $scope.isotope selector
    #  $timeout ->
    #    $(selector).isotope()
    #  , 0

    # $window.webbuddy.module.update_data data


    # ## set up the module. EXTRACT
    # # members of this object work around the unavailability of angular scope to the hosting env when the page is loading.
    # $window.webbuddy.module =
    #   # storage.
    #   data: {}

    #   # applies deltas.
    #   update_data: (data = {})->
    #     new_data = _.clone $window.webbuddy.module.data

    #     # overwrite entries with data.
    #     for key, val of data
    #       new_data[key] = val

    #     # update module.data first.
    #     $window.webbuddy.module.data = new_data

    #     # update the scope.
    #     $scope.$root.data = new_data
    #     $scope.$apply()

    # # post-load update. future updates should be triggered by hosting env.
    # $window.webbuddy.module.update_data()


    # $scope.isotope()

    # , 0


# EXTRACT
angular.module('modulesApp')
  .controller 'ObjTreeCtrl', ($scope) ->

    # dev features.
    $scope.evaluate = (input) ->
      eval_result = eval(input)
      $scope.obj = eval_result

    $scope.obj_keys = (val)->
      if typeof(val) == 'object'
        Object.keys val
      else
        []

    $scope.to_displayable = (val)->
      switch typeof(val)
        when 'object'
          ''
        when 'function'
          String(val)
        else
          val

        # TODO arrays
