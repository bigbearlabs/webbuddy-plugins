'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $timeout, Restangular) ->

    # view consts. unused
    $scope.partials =
      collection: 'views/collection.html'

    $scope.options =
      itemSelector: '.item'
      layoutMode : 'straightAcross'

    $scope.isotope = ->
      # initialise isotope.
      $timeout ->
        $('#isotopeContainer').isotope $scope.options
        $('#isotopeContainer').isotope 'reLayout'
      , 0


    $scope.isotope()

    # attach stub data to root, so the running environment can override it.
    Restangular.setBaseUrl("data");
    Restangular.one('filtering.json').get().then (data) ->
      $scope.update_data data
      # $scope.$apply()

    #   $scope.isotope()


    # dev features.
    $scope.evaluate = (input) ->
      $scope.dev_output = eval(input)

    ## ops.

    $scope.$root.filter = (input)->
      opts =
        filter: ".item:contains(#{input})"
        # itemSelector: '.item'
        # layoutMode : 'straightAcross'

      $timeout ->
        $('#isotopeContainer').isotope opts
        # $('#isotopeContainer').isotope 'reloadItems'
      , 0

    # data exchange interface.
    $scope.$root.update_data = (new_data)->
      # # must mutate $scope.$root.data due to isotope limitations.
      # searches = $scope.data.searches
      # searches.splice 0, searches.length
      # new_data.searches.map (e)-> searches.push e

      # TODO move out to the document and wire as shown in angular-isotope
      $scope.$root.data = new_data
      $scope.$apply()

      # $('#isotopeContainer').isotope 'reloadItems'

      # $('#isotopeContainer').isotope
      #   itemSelector: '.item'
      #   layoutMode : 'straightAcross'

      ## the only way to get this work consistently.
      $('#isotopeContainer').isotope 'destroy'
      $scope.isotope()

