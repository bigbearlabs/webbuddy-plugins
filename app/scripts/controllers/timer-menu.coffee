'use strict'

class RenderableItem
  constructor: (props) ->
    for k, v of props
      @[k] = v

  template: 'basic-text'


angular.module('app')
  .controller 'TimerMenuCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

    $scope.entity_data = [
      new RenderableItem
        description: 'Unnamed Timer'
        on_select: ->
          # make editable.
          # impl:
          # - set contenteditable to true.
          # - set confirm action.
          # - enable confirm trigger.
    ,
    ]

    $scope.menu_data = [
      new RenderableItem
        description: 'Reset'
    ,
      new RenderableItem
        description: '---'
    ,
      new RenderableItem
        description: 'About'
    ,
    ]

