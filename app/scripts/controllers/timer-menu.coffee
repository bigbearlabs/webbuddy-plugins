'use strict'

class RenderableItem
  constructor: (props) ->
    for k, v of props
      @[k] = v

  template: 'basic-text'

  on_select: =>
    console.log "TODO impl on_select for #{JSON.stringify @}"

  edit_done: ->
    console.log "TODO done editing."



angular.module('app')

  .controller 'TimerMenuCtrl',
    (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

      $scope.entity_data = [
        new RenderableItem
          description: 'Unnamed Timer'
          template: 'editable-text'
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



  .directive 'contenteditable', ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      read = ->
        ngModel.$setViewValue(element.html())

      ngModel.$render = ->
        element.html(ngModel.$viewValue || "")

      element.bind "blur keyup change", ->
        scope.$apply read



