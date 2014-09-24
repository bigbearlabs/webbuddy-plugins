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
        # POST deployment request.
        Restangular.all('runs').post 
          apps: apps.map (e) -> e.description
          targets: targets.map (e) -> e.description

        .then (data) ->
          run_id = data.run_id

          $scope.log data

          # poll the results.
          # TODO impl interrupt conditions:
          # - new deployment requested
          # - deployment finished TODO
          # - timed out TODO
          if previous_poll = $scope.poll_promise
            console.log "cancelling previous promise"
            $interval.cancel previous_poll

          $scope.poll_promise = $interval ->
            Restangular.one('runs', run_id).get()
            .then (run) ->
              $scope.log run.log

              if run.state is 'finished'
                $interval ->
                  $interval.cancel $scope.poll_promise
                , 5000

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

