'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $timeout) ->

    # view consts. unused
    $scope.partials =
      collection: 'views/collection.html'

    $scope.options =
      itemSelector: '.item'
      layoutMode : 'straightAcross'

    # attach stub data to root, so the running environment can override it.
    $scope.data =
      input: "stub input"
      searches: [
        {
          name: 'previous search 1'
        }
        {
          name: 'previous search 2'
        }
      ]
      suggestions: [
        'suggestion 1'
        'suggestion 2'
      ]
      pages: [
        'matching page 1'
        'matching page 2'
      ]

    # dev features.
    $scope.evaluate = (input) ->
      $scope.dev_output = eval(input)

    ## ops.

    $scope.$root.filter = ->
      opts =
        filter: ".item:contains(#{$scope.data.input})"
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
      $scope.data = new_data
      $scope.$apply()
      $('#isotopeContainer').isotope 'reloadItems'
      # $('#isotopeContainer').isotope
      #   itemSelector: '.item'
      #   layoutMode : 'straightAcross'


    # # initialise isotope.
    $timeout ->
      $('#isotopeContainer').isotope $scope.options
    , 0
