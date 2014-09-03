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


      $scope.deploy = (apps, destinations) ->
        # package, clone, deploy TODO
        cmd = "TODO #{apps.map (e)-> e.description} to #{destinations.map (e)-> e.description}"

        # update log.
        $scope.data.log = $scope.data.log.concat [
          new RenderableItem
            description: cmd
        ]


      ## doit




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

