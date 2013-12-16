'use strict'

angular.module('modulesApp')
  .controller 'OutputCtrl', ($scope, Restangular, $route) ->

    Restangular.setBaseUrl "data"  # interface with webbuddy-env.

    Restangular.one('output.json').get()
    .then (data)->
      $scope.expression =
        output: data.output


    # debug
    $scope.debug =
      restangular: Restangular
