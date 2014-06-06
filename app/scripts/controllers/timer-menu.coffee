# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('app')
  .controller 'TimerMenuCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

    $scope.entity_data = [
      description: 'Unnamed Timer'
      on_select: ->
        # to editable.
    ,
    ]

    $scope.menu_data = [
      description: 'Reset'
      on_select: 'reset'
    ,
      description: 'about'
      on_select: 'about'
    ,
    ]

