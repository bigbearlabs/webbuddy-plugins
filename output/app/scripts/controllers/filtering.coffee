'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope) ->
    # view consts.
    $scope.partials =
      collection: 'views/collection.html'


    $scope.input = "a test search"

    $scope.data = window.data


window.data =
  suggestions: [
    'suggestion 1'
    'suggestion 2'
  ]
  searches: [
    'previous search 1'
    'previous search 2'
  ]
  pages: [
    'matching page 1'
    'matching page 2'
  ]


# expression for the scope: angular.element(document.getElementsByClassName('container')).scope()
# so one way to interface between execution environment and the module is to define a component executed by the environment, and intefacing is achieved via expressions like the above.
