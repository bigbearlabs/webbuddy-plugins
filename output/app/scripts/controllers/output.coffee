'use strict'

angular.module('modulesApp')
  .controller 'OutputCtrl', ($scope, Restangular, $route) ->

    controllerName = $route.current.$$route.controller.toString()
    moduleName = controllerName.replace( 'Ctrl', '').toLowerCase()

    Restangular.setBaseUrl "data"  # interface with webbuddy-env.

    Restangular.one('output.json').get()
    .then (data)->
      $scope.expression =
        output: 'testtest'


    # debug
    $scope.debug =
      restangular: Restangular
      moduleName: moduleName
      route: $route
