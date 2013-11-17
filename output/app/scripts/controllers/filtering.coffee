'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    $scope.$window = $window   # used by the view layer. UGLY

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


    # dev features.
    $scope.evaluate = (input) ->
      $scope.dev_output = eval(input)


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


    ## data ops.

    # dispatch the rest to avoid ensure setup from host environment has execution priority.
    # $timeout ->

    # @return promise taking (data)->
    $scope.fetch_data = (env = webbuddy.env.name)->
      switch env
        when 'stub'
          # load the data file. # GENERALISE / EXTRACT
          Restangular.setBaseUrl("data");
          Restangular.one('filtering.json').get()
        else
          # return data from the module.data property
          deferred = $q.defer()
          deferred.resolve webbuddy.module.data

          deferred.promise


    ## statics
    $scope.view_model ||=
      limit: 5

    ## webbuddy - module contract
    # set up a stub hosting environment if it hasn't beeen set up already. EXTRACT
    $window.webbuddy ||=
      env:
        name: 'stub'

    # the module object acts as the exchange interface between the hosting env and this module.
    $window.webbuddy.module =
      #init data.
      data: {}  # pvt.

      # data param will be used by hosting env only.
      update_data: (data = null)->
        @data = data unless data?

        $scope.fetch_data().then (data)->
          $scope.$root.data = data

        # FIXME when we move this method out to the module framework, contract needs to change to a property off the global obj, as $scope will not be available when we define behaviour.
        # then we must watch the global prop and update a model prop on the scope.

    ## doit.
    $window.webbuddy.module.update_data()


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

