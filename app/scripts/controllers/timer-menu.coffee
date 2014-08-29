'use strict'


angular.module('app')

  .controller 'TimerMenuCtrl',
    ($scope, $route, $location, $window, $timeout, $q, host_env, Restangular, debounce ) ->

      $scope.select = (item) ->
        item.on_select()

      $scope.edit_done = (item) ->
        host_env.update item.id,
          description: item.description

      # stub
      $scope.data = 
        apps: [
            new RenderableItem
              description: 'WorxMail'
          ,
            new RenderableItem
              description: 'WorxMail-ch'
          ,
            new RenderableItem
              description: 'WorxMail-gb'
          ,
            new RenderableItem
              description: '...'
          ,
          ]
        destinations: [
            new RenderableItem
              description: 'CH-ETIT'
          ,
            new RenderableItem
              description: 'CH-ADIT'
          ]
        log: [
        ]


      ## doit

      # request data for id.
      id = $route.current.params.id

      # throw "id must not be nil" unless id?  # DEBUG
      id ||= 'stub'

      $q.when(host_env.get id)
      .then (data) ->
        items = _.keys(data).map (k)->
          new RenderableItem
            description: data[k]
            template: 'editable-text'

        $scope.entity_data = items
        # $scope.$apply()



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

