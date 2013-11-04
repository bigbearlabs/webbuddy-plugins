'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, Restangular) ->

    $scope.$window = $window

    # view consts. unused
    $scope.partials =
      collection: 'views/collection.html'

    isotope_containers = [ '.search-list', '.page-list', '.suggestion-list' ]

    $scope.options =
      itemSelector: '.item'
      layoutMode: 'straightDown'
      # layoutMode: 'straightAcross'


    # watch model.
    $scope.$watch 'data.input', ->
      $scope.filter $scope.data?.input

    # initialise isotope.
    $scope.isotope = (selector_for_container, options = $scope.options)->
      # $timeout ->
      #   # re-isotope
      #   $(selector_for_container).isotope options

      #   # hide elems after limit
      #   # $(selector_for_container).find('.item:gt(4)').
      # , 0

    # dev features.
    $scope.evaluate = (input) ->
      $scope.dev_output = eval(input)


    ## ops.

    $scope.click_item = (item)->
      console.log "#{item} clicked!"

      # TODO toggle member view.


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

    # data exchange interface.
    $scope.$root.update_data = (new_data)->
      # # must mutate $scope.$root.data due to isotope limitations.
      # searches = $scope.data.searches
      # searches.splice 0, searches.length
      # new_data.searches.map (e)-> searches.push e

      # TODO move out to the document and wire as shown in angular-isotope
      $scope.$root.data = new_data
      # $scope.$apply()

      # $timeout ->
      #   # isotope item acquisition somehow unstable without this call
      #   isotope_containers.map (selector)->
      #     $(selector).isotope 'reloadItems'
      # , 0

      # $('#isotopeContainer').isotope
      #   itemSelector: '.item'
      #   layoutMode : 'straightAcross'

      # ## the only way to get this work consistently.
      # isotope_containers.map (selector)->
      #   $timeout ->
      #     $(selector).isotope 'destroy'
      #     $scope.isotope selector
      #   , 0


    ## doit.

    $scope.view_model ||=
      limit: 5
    $scope.$root.data ||= {}

    ## dev
    # attach stub data to root, so the running environment can override it.
    Restangular.setBaseUrl("data");
    Restangular.one('filtering.json').get().then (data) ->
      # isotope_containers.map (selector)->
      #  $scope.isotope selector
      #  $timeout ->
      #    $(selector).isotope()
      #  , 0

      $scope.update_data data


    # $scope.isotope()



