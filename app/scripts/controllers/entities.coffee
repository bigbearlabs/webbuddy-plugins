'use strict'


angular.module('app')

  .controller 'EntitiesCtrl',
    ($scope, $route, $location, $window, $interval, $q, host_env, Restangular, debounce ) ->
      $scope.data = 
        apps: []
        targets: []
        log: []

      $scope.select = (item) ->
        item.on_select()

      $scope.edit_done = (item) ->
        host_env.update item.id,
          description: item.description


      $scope.deploy = (apps, targets) ->
        # package, clone, deploy TODO
        # cmd = "TODO #{apps.map (e)-> e.description} to #{targets.map (e)-> e.description}"

        # POST deployment request. TODO
        Restangular.all('runs').post 
          apps: apps.map (e) -> e.description
          targets: targets.map (e) -> e.description
        .then (data) ->
          run_id = 'stub'

          $scope.log data

          # poll.
          $interval ->
            Restangular.one('runs', run_id).get()
            .then (run) ->
              $scope.log run.log

          , 5000
              


      $scope.log = (msg) ->
        $scope.data.log = msg


      ## doit
      Restangular.setBaseUrl("#{$location.protocol()}://#{$location.host()}:9292")
      
      Restangular.all('apps').getList()
        .then (apps)->
          $scope.data.apps = apps.map (e) ->
            new RenderableItem
              description: e.id
              model: e
          
          # $scope.$apply()
      Restangular.all('targets').getList()
        .then (targets)->
          $scope.data.targets = targets.map (e) ->
            new RenderableItem
              description: e.id
              model: e



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

